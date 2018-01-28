module sbylib.wrapper.gl.FrameBuffer;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import derelict.opengl;

class FrameBuffer {

    private immutable uint id;

    invariant {
        assert(id > 0);
    }

    this() out {
        GlFunction.checkError();
    } body {
        uint id;
        glGenFramebuffers(1, &id);
        this.id = id;
    }

    ~this() out {
        GlFunction.checkError();
    } body {
        glDeleteBuffers(1, &id);
    }

    void bind(FrameBufferBindType type) const out {
        GlFunction.checkError();
    } body {
        glBindFramebuffer(type, this.id);
    }

    void unbind(FrameBufferBindType type) const out {
        GlFunction.checkError();
    } body {
        glBindFramebuffer(type, 0);
    }
}
