module sbylib.wrapper.gl.RenderBuffer;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import derelict.opengl;

class RenderBuffer {

    private immutable uint id;
    private bool allocated;
    private bool alive = true;

    this() out {
       GlFunction.checkError(); 
    } body {
        uint id;
        glGenRenderbuffers(1, &id);
        this.id = id;
    }

    this(uint width, uint height, ImageInternalFormat format) {
        this();
        this.allocate(width, height, format);
    }

    void destroy() in {
        assert(alive);
    } out {
        GlFunction.checkError();
    } body {
        alive = false;
        glDeleteRenderbuffers(1, &id);
    }

    void bind() in {
        assert(alive);
    } out {
        GlFunction.checkError();
    } body {
        glBindRenderbuffer(RenderBufferBindType.Both, this.id);
    }

    void unbind() in {
        assert(alive);
    } out {
        GlFunction.checkError();
    } body {
        glBindRenderbuffer(RenderBufferBindType.Both, 0);
    }

    void allocate(uint width, uint height, ImageInternalFormat format) out {
        GlFunction.checkError();
    } body {
        this.bind();
        glRenderbufferStorage(RenderBufferBindType.Both, format, width, height);
        this.unbind();
        this.allocated = true;
    }

    void attachFrameBuffer(FrameBufferBindType bindType, FrameBufferAttachType attachType) in {
        assert(this.allocated);
    } out {
        GlFunction.checkError();
    } body {
        this.bind();
        glFramebufferRenderbuffer(bindType, attachType, RenderBufferBindType.Both, this.id);
        this.unbind();
    }
}
