module sbylib.gl.FrameBuffer;

import sbylib.gl;
import derelict.opengl;

class FrameBuffer {

    private immutable uint id;

    this() {
        uint id;
        glGenFramebuffers(1, &id);
        this.id = id;
    }

    ~this() {
        glDeleteBuffers(1, &id);
    }

    private void bind(FrameBufferBindType type) {
        glBindFramebuffer(type, this.id);
    }

    private void unbind(FrameBufferBindType type) {
        glBindFramebuffer(type, this.id);
    }

    void attachTexture(Texture tex, FrameBufferBindType bindType, FrameBufferAttachType attachType) {
        glFramebufferTexture2D(bindType, attachType, GL_TEXTURE_2D, tex ? tex.texID : 0, 0);
    }
}
