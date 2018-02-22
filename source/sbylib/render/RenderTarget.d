module sbylib.render.RenderTarget;

import sbylib.math.Vector;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.FrameBuffer;
import sbylib.wrapper.gl.RenderBuffer;
import sbylib.wrapper.gl.Texture;

import std.algorithm;
import std.stdio;

interface IRenderTarget {

    const(FrameBuffer) getFrameBuffer();
    int getWidth();
    int getHeight();

    final void renderBegin() {
        getFrameBuffer().bind(FrameBufferBindType.Both);
    }

    final void renderEnd() {
        getFrameBuffer().unbind(FrameBufferBindType.Both);
    }

    final void blitsTo(IRenderTarget dstRenderTarget, ClearMode[] mode...) {
        auto dst = dstRenderTarget.getFrameBuffer();
        this.getFrameBuffer().blitsTo(dst, 0, 0, this.getWidth(), this.getHeight(), 0, 0, dstRenderTarget.getWidth(), dstRenderTarget.getHeight(), TextureFilter.Linear, mode);
    }

    void setClearColor(vec4);
    void setClearStencil(int);
    void clear(ClearMode[]...);
}

class RenderTarget : IRenderTarget {
    private FrameBuffer frameBuffer;
    private Texture[FrameBufferAttachType] textures;
    private uint width, height;
    private vec4 clearColor = vec4(0, .5, .5, 1);
    private int clearStencil;

    this(uint width, uint height) {
        this.frameBuffer = new FrameBuffer();
        this.width = width;
        this.height = height;
    }

    void destroy() {
        this.frameBuffer.destroy();
    }

    void attachTexture(T)(FrameBufferAttachType attachType) {
        Texture tex = new Texture(TextureTarget.Tex2D, 0, this.getInternalFormat(attachType), this.width, this.height, ImageFormat.RGBA, cast(T*)null);
        this.attach(tex, attachType);
    }

    void attachRenderBuffer(FrameBufferAttachType attachType) {
        RenderBuffer rbo = new RenderBuffer(this.width, this.height, this.getInternalFormat(attachType));
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

    private ImageInternalFormat getInternalFormat(FrameBufferAttachType attachType) {
        switch (attachType) {
            case FrameBufferAttachType.Color0, FrameBufferAttachType.Color1, FrameBufferAttachType.Color2:
                return ImageInternalFormat.RGBA;
            case FrameBufferAttachType.Depth:
                return ImageInternalFormat.Depth;
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

    override void setClearColor(vec4 color) {
        this.clearColor = color;
    }

    override void setClearStencil(int stencil) {
        this.clearStencil = stencil;
    }

    override void clear(ClearMode[] clearMode...) {
        if (clearMode.canFind(ClearMode.Color)) {
            GlFunction.clearColor(this.clearColor);
        }
        if (clearMode.canFind(ClearMode.Stencil)) {
            GlFunction.clearStencil(this.clearStencil);
        }
        this.renderBegin();
        GlFunction.clear(clearMode);
        this.renderEnd();
    }

    override const(FrameBuffer) getFrameBuffer() {
        return this.frameBuffer;
    }

    override int getWidth() {
        return this.width;
    }

    override int getHeight() {
        return this.height;
    }
}
