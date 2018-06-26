module sbylib.render.RenderTarget;

import sbylib.math.Vector;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.FrameBuffer;
import sbylib.wrapper.gl.RenderBuffer;
import sbylib.wrapper.gl.Texture;

import std.algorithm;
import std.stdio;

abstract class IRenderTarget {
    
    private vec4 clearColor = vec4(0, .5, .5, 1);
    private int clearStencil = 0;
    private debug bool hasCleared;

    const(FrameBuffer) getFrameBuffer();
    int width();
    int height();

    final void renderBegin() {
        getFrameBuffer().bind(FrameBufferBindType.Both);
    }

    final void renderEnd() in {
        debug assert(hasCleared, "RenderTarget has not been cleared");
    } body {
        getFrameBuffer().unbind(FrameBufferBindType.Both);
    }

    final void blitsTo(IRenderTarget dstRenderTarget, ClearMode[] mode...) {
        auto dst = dstRenderTarget;
        blitsTo(dstRenderTarget, 0, 0, dst.width, dst.height, mode);
    }

    final void blitsTo(IRenderTarget dstRenderTarget, int x, int y, int w, int h, ClearMode[] mode...) {
        auto src = this;
        this.getFrameBuffer().blitsTo(
                dstRenderTarget.getFrameBuffer(),
                0, 0, src.width, src.height,
                x, y, w, h, TextureFilter.Nearest, mode);
    }

    void clear(ClearMode[] clearMode...) {
        if (clearMode.canFind(ClearMode.Color)) {
            GlFunction.clearColor(this.clearColor);
        }
        if (clearMode.canFind(ClearMode.Stencil)) {
            GlFunction.clearStencil(this.clearStencil);
        }
        this.renderBegin();
        GlFunction.clear(clearMode);
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
    private FrameBuffer frameBuffer;
    private Texture[FrameBufferAttachType] textures;
    private uint mWidth, mHeight;
    private vec4 clearColor = vec4(0, .5, .5, 1);
    private int clearStencil;
    private debug bool hasCleared;

    this(uint width, uint height) {
        this.frameBuffer = new FrameBuffer();
        this.mWidth = width;
        this.mHeight = height;
    }

    void destroy() {
        this.frameBuffer.destroy();
    }

    void attachTexture(T)(FrameBufferAttachType attachType) {
        Texture tex = new Texture(
            TextureTarget.Tex2D,
            0,
            this.getInternalFormat!T(attachType),
            this.width, this.height,
            this.getImageFormat(attachType),
            cast(T*)null);
        this.attach(tex, attachType);
    }

    void attachTexture(Texture tex, FrameBufferAttachType attachType) {
        this.attach(tex, attachType);
    }

    void attachRenderBuffer(T)(FrameBufferAttachType attachType) {
        RenderBuffer rbo = new RenderBuffer(this.width, this.height, this.getInternalFormat!T(attachType));
        this.attach(rbo, attachType);
    }

    private void attach(RenderBuffer renderBuffer, FrameBufferAttachType attachType) in {
        assert(this.frameBuffer);
    } body {
        this.frameBuffer.bind(FrameBufferBindType.Both);
        renderBuffer.attachFrameBuffer(FrameBufferBindType.Both, attachType);
        this.frameBuffer.unbind(FrameBufferBindType.Both);
    }

    private void attach(Texture texture, FrameBufferAttachType attachType) in {
        assert(this.frameBuffer);
    } body {
        this.frameBuffer.bind(FrameBufferBindType.Both);
        texture.attachFrameBuffer(FrameBufferBindType.Both, attachType);
        this.frameBuffer.unbind(FrameBufferBindType.Both);
        this.textures[attachType] = texture;
    }

    private ImageFormat getImageFormat(FrameBufferAttachType attachType) {
        switch (attachType) {
            case FrameBufferAttachType.Color0, FrameBufferAttachType.Color1, FrameBufferAttachType.Color2:
                return ImageFormat.RGBA;
            case FrameBufferAttachType.Depth:
                return ImageFormat.Depth;
            case FrameBufferAttachType.DepthStencil:
                return ImageFormat.DepthStencil;
            default:
                assert(false);
        }
    }

    private ImageInternalFormat getInternalFormat(Type)(FrameBufferAttachType attachType) {
        switch (attachType) {
            case FrameBufferAttachType.Color0, FrameBufferAttachType.Color1, FrameBufferAttachType.Color2:
                static if (is(Type == float)) {
                    return ImageInternalFormat.RGBA32F;
                } else {
                    return ImageInternalFormat.RGBA;
                }
            case FrameBufferAttachType.Depth:
                return ImageInternalFormat.Depth;
            case FrameBufferAttachType.Stencil:
                return ImageInternalFormat.Stencil;
            case FrameBufferAttachType.DepthStencil:
                return ImageInternalFormat.DepthStencil;
            default:
                assert(false);
        }
    }

    Texture getColorTexture()  {
        return textures[FrameBufferAttachType.Color0];
    }

    Texture getDepthTexture()  {
        return textures[FrameBufferAttachType.Depth];
    }

    Texture getStencilTexture()  {
        return textures[FrameBufferAttachType.Stencil];
    }

    override const(FrameBuffer) getFrameBuffer() {
        return this.frameBuffer;
    }

    override int width() {
        return this.mWidth;
    }

    override int height() {
        return this.mHeight;
    }
}
