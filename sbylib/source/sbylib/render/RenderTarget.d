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

    final void renderEnd()
    in {
        debug assert(hasCleared, "RenderTarget has not been cleared");
    }
    do {
        getFramebuffer().unbind(FramebufferBindType.Both);
    }

    final void blitsTo(IRenderTarget dstRenderTarget, ClearMode[] mode...) {
        auto dst = dstRenderTarget;
        blitsTo(dstRenderTarget, 0, 0, dst.width, dst.height, mode);
    }

    final void blitsTo(IRenderTarget dstRenderTarget, int x, int y, int w, int h, ClearMode[] mode...) {
        this.getFramebuffer().blitsTo(
            dstRenderTarget.getFramebuffer(),
            0, 0, this.width, this.height,
            x, y, w, h, TextureFilter.Nearest, mode);
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
    private Framebuffer frameBuffer;
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

    private FramebufferAttachType getColorAttachType(int n) {
        final switch (n) {
            case 0: return FramebufferAttachType.Color0;
            case 1: return FramebufferAttachType.Color1;
            case 2: return FramebufferAttachType.Color2;
        }
    }

    Texture getColorTexture(int n = 0)  {
        return textures[getColorAttachType(n)];
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
