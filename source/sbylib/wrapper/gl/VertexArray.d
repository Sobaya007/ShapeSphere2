module sbylib.wrapper.gl.VertexArray;

import sbylib.wrapper.gl;
import derelict.opengl;
import std.algorithm;

class VertexArray {

    immutable uint id;

    this() {
        uint vao;
        glGenVertexArrays(1, &vao);
        this.id = vao;
    }

    ~this() {
        glDeleteVertexArrays(1, &id);
    }

    void attachBuffers(VertexBuffer[] buffers) {
        this.bind();
        buffers.each!(buffer => buffer.bind());
        this.unbind();
    }

    private void bind() const {
        glBindVertexArray(id);
    }

    private void unbind() const {
        glBindVertexArray(0);
    }
}
