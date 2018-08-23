module sbylib.render.RenderTarget;

import sbylib.math.Vector;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.Framebuffer;
import sbylib.wrapper.gl.Renderbuffer;
import sbylib.wrapper.gl.Texture;

import std.algorithm;
import std.stdio;

abstract class IRenderTarget {
    
    private vec4 clearColor = vec4(0, .2, .5, 1);
    private int clearStencil = 0;
    private debug bool hasCleared;

    const(Framebuffer) getFramebuffer() out(r; r !is null);
    int width();
    int height();

    void renderBegin() {
        getFramebuffer().bind(FramebufferBindType.Both);
    }

    void renderEnd()
    in {
        debug assert(hasCleared, "RenderTarget has not been cleared");
    }
    do {
        getFramebuffer().unbind(FramebufferBindType.Both);
    }

    final void blitsTo(IRenderTarget dst, BufferBit[] mode...) {
        blitsTo(dst, 0, 0, dst.width, dst.height, mode);
    }

    void blitsTo(IRenderTarget dstRenderTarget, int x, int y, int w, int h, BufferBit[] mode...) {
        blitsTo(0, 0, this.width, this.height, dstRenderTarget, x, y, w, h, mode);
    }

    void blitsTo(int sx, int sy, int sw, int sh, IRenderTarget dstRenderTarget, int dx, int dy, int dw, int dh, BufferBit[] mode...) {
        this.getFramebuffer().blitsTo(
            dstRenderTarget.getFramebuffer(),
            sx, sy, sw, sh,
            dx, dy, dw, dh, TextureFilter.Nearest, mode);
    }

    void clear(ClearMode[] clearMode...) {
        if (clearMode.canFind(ClearMode.Color)) {
            GlUtils.clearColor(this.clearColor);
        }
        if (clearMode.canFind(ClearMode.Stencil)) {
            GlFunction().clearStencil(this.clearStencil);
        }
        this.renderBegin();
        GlFunction().clear(clearMode);
        debug this.hasCleared = true;
        this.renderEnd();
    }

    final void setClearColor(vec4 color) {
        this.clearColor = color;
    }

    final void setClearStencil(int stencil) {
        this.clearStencil = stencil;
    }
}

class RenderTarget : IRenderTarget {
    import sbylib.core.Window;

    private Framebuffer frameBuffer;
    private Renderbuffer[FramebufferAttachType] rbos;
    private Texture[FramebufferAttachType] textures;
    private uint mWidth, mHeight;
    private vec4 clearColor = vec4(0, .5, .5, 1);
    private int clearStencil;
    private FramebufferAttachType[] attachedColors;
    private debug bool hasCleared;

    this(uint width, uint height) {
        this(new Framebuffer(), width, height);
    }

    this(Framebuffer frameBuffer, uint width, uint height) 
        in(frameBuffer !is null)
    {
        this.frameBuffer = frameBuffer;
        this.mWidth = width;
        this.mHeight = height;
    }

    override void renderBegin() {
        super.renderBegin();
        GlFunction().drawBuffers(this.attachedColors);
    }

    override void renderEnd() {
        GlFunction().drawBuffers([FramebufferAttachType.Color0]);
        super.renderEnd();
    }

    override void blitsTo(IRenderTarget dst, int x, int y, int w, int h, BufferBit[] mode...) {
        if (auto dst2 = cast(RenderTarget)dst) {
            import std.range;
            foreach (type; this.attachedColors.sort) {
                if (!GlUtils.isColorAttachType(type)) continue;
                this.frameBuffer.setReadBuffer(type);
                dst2.frameBuffer.setDrawBuffer(type);
                super.blitsTo(dst,x, y, w, h, mode);
            }
            this.frameBuffer.setReadBuffer(FramebufferAttachType.Color0);
        } else {
            super.blitsTo(dst,x, y, w, h, mode);
        }
    }

    void resize(int width, int height) {
        this.mWidth = width;
        this.mHeight = height;
        foreach (type, rbo; rbos) {
            rbo.reallocate(this.width, this.height);
        }
        foreach (type, texture; textures) {
            texture.reallocate(0, this.width, this.height);
        }
    }

    RenderTarget clone() {
        auto result = new RenderTarget(this.width, this.height);
        foreach (type, rbo; rbos) {
            result.attach(rbo.clone(), type);
        }
        foreach (type, tex; textures) {
            result.attach(tex.clone(), type);
        }
        return result;
    }

    void clearAttachment() {
        this.frameBuffer.bind(FramebufferBindType.Both);
        foreach (type, rbo; rbos) {
            rbo.detachFramebuffer(FramebufferBindType.Both, type);
        }
        foreach (type, tex; textures) {
            tex.detachFramebuffer(FramebufferBindType.Both, type);
        }
        this.frameBuffer.unbind(FramebufferBindType.Both);
        rbos = null;
        textures = null;
        attachedColors = null;
    }

    void attachTexture(T)(FramebufferAttachType attachType) {
        Texture tex = new Texture(
            TextureTarget.Tex2D,
            0,
            this.getInternalFormat!T(attachType),
            this.width, this.height,
            this.getImageFormat(attachType),
            cast(T*)null);
        this.attach(tex, attachType);
    }

    void attachTexture(Texture tex, FramebufferAttachType attachType) {
        this.attach(tex, attachType);
    }

    void attachRenderbuffer(T)(FramebufferAttachType attachType) {
        Renderbuffer rbo = new Renderbuffer(this.width, this.height, this.getInternalFormat!T(attachType));
        this.attach(rbo, attachType);
    }

    private void attach(Renderbuffer renderBuffer, FramebufferAttachType attachType) {
        this.registerAttachType(attachType);
        this.frameBuffer.bind(FramebufferBindType.Both);
        renderBuffer.attachFramebuffer(FramebufferBindType.Both, attachType);
        this.frameBuffer.unbind(FramebufferBindType.Both);
        this.rbos[attachType] = renderBuffer;
    }

    private void attach(Texture texture, FramebufferAttachType attachType) {
        this.registerAttachType(attachType);
        this.frameBuffer.bind(FramebufferBindType.Both);
        texture.attachFramebuffer(FramebufferBindType.Both, attachType);
        this.frameBuffer.unbind(FramebufferBindType.Both);
        this.textures[attachType] = texture;
    }

    private void registerAttachType(FramebufferAttachType type) {
        switch (type) {
        case FramebufferAttachType.Color0:
        case FramebufferAttachType.Color1:
        case FramebufferAttachType.Color2:
            this.attachedColors ~= type;
            return;
        default:
            return;
        }
    }

    private ImageFormat getImageFormat(FramebufferAttachType attachType) {
        switch (attachType) {
            case FramebufferAttachType.Color0, FramebufferAttachType.Color1, FramebufferAttachType.Color2:
                return ImageFormat.RGBA;
            case FramebufferAttachType.Depth:
                return ImageFormat.Depth;
            case FramebufferAttachType.Stencil:
                return ImageFormat.Stencil;
            case FramebufferAttachType.DepthStencil:
                return ImageFormat.DepthStencil;
            default:
                assert(false);
        }
    }

    private ImageInternalFormat getInternalFormat(Type)(FramebufferAttachType attachType) {
        switch (attachType) {
            case FramebufferAttachType.Color0, FramebufferAttachType.Color1, FramebufferAttachType.Color2:
                static if (is(Type == float)) {
                    return ImageInternalFormat.RGBA32F;
                } else {
                    return ImageInternalFormat.RGBA;
                }
            case FramebufferAttachType.Depth:
                return ImageInternalFormat.Depth;
            case FramebufferAttachType.Stencil:
                return ImageInternalFormat.Stencil;
            case FramebufferAttachType.DepthStencil:
                return ImageInternalFormat.DepthStencil;
            default:
                assert(false);
        }
    }

    auto getColorTextures() {
        import std.algorithm : filter;
        return textures
            .byKeyValue
            .filter!(p => GlUtils.isColorAttachType(p.key));
    }

    Texture getColorTexture(size_t n = 0)  {
        return textures[GlUtils.getFramebufferColorAttachType(n)];
    }

    Texture getDepthTexture()  {
        return textures[FramebufferAttachType.Depth];
    }

    Texture getStencilTexture()  {
        return textures[FramebufferAttachType.Stencil];
    }

    override const(Framebuffer) getFramebuffer() {
        return this.frameBuffer;
    }

    override int width() {
        return this.mWidth;
    }

    override int height() {
        return this.mHeight;
    }
}
