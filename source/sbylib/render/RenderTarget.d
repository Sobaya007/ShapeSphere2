module sbylib.render.RenderTarget;

import sbylib.math.Vector;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.FrameBuffer;
import sbylib.wrapper.gl.RenderBuffer;
import sbylib.wrapper.gl.Texture;

import std.algorithm;

interface IRenderTarget {
    void renderBegin();
    void renderEnd();
    void setClearColor(vec4);
    void setClearStencil(int);
    void clear(ClearMode[]...);
    int getWidth();
    int getHeight();
}

class RenderTarget : IRenderTarget {
    private const FrameBuffer frameBuffer;
    private Texture[FrameBufferAttachType] textures;
    private uint width, height;
    private vec4 clearColor = vec4(0, .5, .5, 1);
    private int clearStencil;

    this(uint width, uint height) {
        this.frameBuffer = new FrameBuffer();
        this.width = width;
        this.height = height;
    }

    void attachTexture(T)(FrameBufferAttachType attachType) {
        Texture tex = new Texture(TextureTarget.Tex2D, 0, ImageInternalFormat.RGBA, this.width, this.height, ImageFormat.RGBA, cast(T*)null);
        this.attach(tex, attachType);
    }

    void attachRenderBuffer(FrameBufferAttachType attachType) {
        RenderBuffer rbo = new RenderBuffer();
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

    Texture getColorTexture()  {
        return textures[FrameBufferAttachType.Color0];
    }

    Texture getDepthTexture()  {
        return textures[FrameBufferAttachType.Depth];
    }

    override void renderBegin() {
        this.frameBuffer.bind(FrameBufferBindType.Both);
    }

    override void renderEnd() {
        this.frameBuffer.unbind(FrameBufferBindType.Both);
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
        GlFunction.clear(clearMode);
    }

    override int getWidth() {
        return this.width;
    }

    override int getHeight() {
        return this.height;
    }
}