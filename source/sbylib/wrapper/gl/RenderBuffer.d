module sbylib.wrapper.gl.RenderBuffer;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import derelict.opengl;

class RenderBuffer {

    private immutable uint id;

    this() out {
       checkGlError(); 
    } body {
        uint id;
        glGenRenderbuffers(1, &id);
        this.id = id;
    }

    ~this() out {
        checkGlError();
    } body {
        glDeleteRenderbuffers(1, &id);
    }

    void bind() out {
        checkGlError();
    } body {
        glBindRenderbuffer(RenderBufferBindType.Both, id);
    }

    void unBind() out {
        checkGlError();
    } body {
        glBindRenderbuffer(RenderBufferBindType.Both, 0);
    }

    void attachFrameBuffer(FrameBufferBindType bindType, FrameBufferAttachType attachType) out {
        checkGlError();
    } body {
        glFramebufferRenderbuffer(bindType, attachType, RenderBufferBindType.Both, this.id);
    }
}
