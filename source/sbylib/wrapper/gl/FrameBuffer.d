module sbylib.wrapper.gl.FrameBuffer;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import derelict.opengl;

class FrameBuffer {

    private immutable uint id;

    this() out {
        checkGlError();
    } body {
        uint id;
        glGenFramebuffers(1, &id);
        this.id = id;
    }

    ~this() out {
        checkGlError();
    } body {
        glDeleteBuffers(1, &id);
    }

    void bind(FrameBufferBindType type) const out {
        checkGlError();
    } body {
        glBindFramebuffer(type, this.id);
    }

    void unbind(FrameBufferBindType type) const out {
        checkGlError();
    } body {
        glBindFramebuffer(type, 0);
    }
}
