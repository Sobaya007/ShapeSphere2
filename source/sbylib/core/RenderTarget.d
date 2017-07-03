module sbylib.core.RenderTarget;

import sbylib.math.Vector;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.FrameBuffer;
import sbylib.wrapper.gl.RenderBuffer;
import sbylib.wrapper.gl.Texture;
import sbylib.wrapper.glfw.Window;

import std.algorithm;

class RenderTarget {

    private const FrameBuffer frameBuffer;

    private Texture[FrameBufferAttachType] textures;
    const uint width, height;
    uint viewportX, viewportY, viewportWidth, viewportHeight;
    vec4 clearColor = vec4(0, .5, .5, 1);
    int clearStencil;

    this(uint width, uint height) {
        this.frameBuffer = new FrameBuffer();
        this.width = width;
        this.height = height;
        this.viewportX = 0;
        this.viewportY = 0;
        this.viewportWidth = width;
        this.viewportHeight = height;
    }

    this(Window window) {
        this.frameBuffer = null;
        this.width = window.getWidth();
        this.height = window.getHeight();
        this.viewportX = 0;
        this.viewportY = 0;
        this.viewportWidth = width;
        this.viewportHeight = height;
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

    void renderBegin() {
        if (!this.frameBuffer) return;
        this.frameBuffer.bind(FrameBufferBindType.Both);
    }

    void renderEnd() {
        if (!this.frameBuffer) return;
        this.frameBuffer.unbind(FrameBufferBindType.Both);
    }
   
    void clear(ClearMode[] clearMode...) {
        if (clearMode.canFind(ClearMode.Color)) {
            GlFunction.clearColor(this.clearColor);
        }
        if (clearMode.canFind(ClearMode.Stencil)) {
            GlFunction.clearStencil(this.clearStencil);
        }
        GlFunction.clear(clearMode);
    }
}
