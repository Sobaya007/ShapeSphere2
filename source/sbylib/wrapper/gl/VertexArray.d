module sbylib.wrapper.gl.VertexArray;

import sbylib.wrapper.gl.Program;
import sbylib.wrapper.gl.Attribute;
import sbylib.wrapper.gl.VertexBuffer;
import sbylib.wrapper.gl.IndexBuffer;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import derelict.opengl;
import std.algorithm;
import std.typecons;

class VertexArray {

    immutable uint id;

    this() {
        uint vao;
        glGenVertexArrays(1, &vao);
        this.id = vao;
    }

    ~this() {
        //        glDeleteVertexArrays(1, &id);
    }

    void bind() const {
        glBindVertexArray(id);
    }

    void unbind() const {
        glBindVertexArray(0);
    }

    void setup(const Program program, Tuple!(Attribute, VertexBuffer)[] buffers, IndexBuffer ibo) {
        this.bind();
        foreach(tuple; buffers) {
            program.enableAttribute(tuple[0]);
            tuple[1].bind();
            program.attachAttribute(tuple[0], tuple[1]);
        }
        ibo.bind();
        this.unbind();
    }

    void drawArrays(Prim prim, uint offset, uint count) {
        this.bind();
        glDrawArrays(prim, offset, count);
        this.unbind();
    }

    void drawElements(IndexType)(Prim prim, IndexType[] indices)
    if (is(IndexType == ubyte) || is(IndexType == ushort) || is(IndexType == uint)) {
        this.bind();
        glDrawElements(prim, indices.length, getTypeEnum!(IndexType), indices.ptr);
        this.unbind();
    }

    void drawElements(IndexType)(Prim prim, uint count)
    if (is(IndexType == ubyte) || is(IndexType == ushort) || is(IndexType == uint)) {
        this.bind();
        glDrawElements(prim, count, getTypeEnum!(IndexType), null);
        this.unbind();
    }
}
