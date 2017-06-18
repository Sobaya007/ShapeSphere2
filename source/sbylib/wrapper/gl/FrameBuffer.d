module sbylib.wrapper.gl.FrameBuffer;

import sbylib.wrapper.gl;
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

    void bind(FrameBufferBindType type) const {
        glBindFramebuffer(type, this.id);
    }

    void unbind(FrameBufferBindType type) const {
        glBindFramebuffer(type, 0);
    }
}
