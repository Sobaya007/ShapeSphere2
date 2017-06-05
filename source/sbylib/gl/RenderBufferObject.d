module sbylib.gl.RenderBufferObject;

import sbylib.gl;
import derelict.opengl;

class RenderBufferObject {
    immutable uint id;

    this() {
        uint id;
        glGenRenderbuffers(1, &id);
        this.id = id;
    }

    ~this() {
        glDeleteRenderbuffers(1, &id);
    }

    void bind() {
        glBindRenderbuffer(GL_RENDERBUFFER, id);
    }

    void unBind() {
        glBindRenderbuffer(GL_RENDERBUFFER, 0);
    }
}
