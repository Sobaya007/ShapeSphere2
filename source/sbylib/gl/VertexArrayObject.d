module sbylib.gl.VertexArrayObject;

import sbylib.gl;
import derelict.opengl;

class VertexArrayObject(T) {

    alias VertexBufferObject!T VBO_T;
    immutable uint vaoID;

    private immutable Prim drawType;

@nogc:

    this(Prim type = Prim.TriangleStrip) {
        uint vao;
        glGenVertexArrays(1, &vao);
        this.vaoID = vao;
        this.drawType = type;
    }

    ~this() {
        glDeleteVertexArrays(1, &vaoID);
    }

    void bind() const {
        glBindVertexArray(vaoID);
    }

    void unBind() const {
        glBindVertexArray(0);
    }

    void draw() const {
        glDrawArrays(drawType, 0, 4);
    }

    void draw(IBO index) const {
        glDrawElements(drawType, index.length, GL_UNSIGNED_INT, null);
    }
}

alias VertexArrayObject!float VAO;
