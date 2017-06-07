module sbylib.gl.RenderBuffer;

import sbylib.gl;
import derelict.opengl;

class RenderBuffer {

    private immutable uint id;

    this() {
        uint id;
        glGenRenderbuffers(1, &id);
        this.id = id;
    }

    ~this() {
        glDeleteRenderbuffers(1, &id);
    }

    void bind() {
        glBindRenderbuffer(RenderBufferBindType.Both, id);
    }

    void unBind() {
        glBindRenderbuffer(RenderBufferBindType.Both, 0);
    }

    void attachFrameBuffer(FrameBufferBindType bindType, FrameBufferAttachType attachType) {
        glFramebufferRenderbuffer(bindType, attachType, RenderBufferBindType.Both, this.id);
    }
}
