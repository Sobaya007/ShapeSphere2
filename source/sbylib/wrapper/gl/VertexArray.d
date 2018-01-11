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
import std.format;

class VertexArray {

    immutable uint id;

    this() out {
        GlFunction.checkError();
    } body {
        uint vao;
        glGenVertexArrays(1, &vao);
        this.id = vao;
    }

    ~this() {
        this.destroy();
    }

    void destroy() out {
        GlFunction.checkError();
    } body {
        glDeleteVertexArrays(1, &this.id);
    }

    void bind() const out {
        GlFunction.checkError(format!"%d"(this.id));
    } body {
        glBindVertexArray(id);
    }

    void unbind() const out {
        GlFunction.checkError();
    } body {
        glBindVertexArray(0);
    }

    void setup(const Program program, Tuple!(Attribute, VertexBuffer)[] buffers, IndexBuffer ibo) {
        this.bind();
        foreach(tuple; buffers) {
            if (!program.hasAttribute(tuple[0].name)) continue;
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
        GlFunction.checkError();
        this.unbind();
    }

    void drawElements(IndexType)(Prim prim, IndexType[] indices)
    if (is(IndexType == ubyte) || is(IndexType == ushort) || is(IndexType == uint)) {
        this.bind();
        glDrawElements(prim, indices.length, getTypeEnum!(IndexType), indices.ptr);
        GlFunction.checkError();
        this.unbind();
    }

    void drawElements(IndexType)(Prim prim, uint count)
    if (is(IndexType == ubyte) || is(IndexType == ushort) || is(IndexType == uint)) {
        this.bind();
        glDrawElements(prim, count, GlFunction.getTypeEnum!(IndexType), null);
        GlFunction.checkError();
        this.unbind();
    }
}
