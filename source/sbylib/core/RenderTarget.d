module sbylib.core.RenderTarget;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.FrameBuffer;
import sbylib.wrapper.gl.RenderBuffer;
import sbylib.wrapper.gl.Texture;

class RenderTarget {

    private const FrameBuffer frameBuffer;

    private Texture[FrameBufferAttachType] textures;
    const uint width, height;

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

    private void attach(RenderBuffer renderBuffer, FrameBufferAttachType attachType) {
        this.frameBuffer.bind(FrameBufferBindType.Both);
        renderBuffer.attachFrameBuffer(FrameBufferBindType.Both, attachType);
        this.frameBuffer.unbind(FrameBufferBindType.Both);
    }

    private void attach(Texture texture, FrameBufferAttachType attachType) {
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
        this.frameBuffer.bind(FrameBufferBindType.Both);
    }

    void renderEnd() {
        this.frameBuffer.unbind(FrameBufferBindType.Both);
    }
}
