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

    this() out {
        checkGlError();
    } body {
        uint vao;
        glGenVertexArrays(1, &vao);
        this.id = vao;
    }

    ~this() out {
        checkGlError();
    } body {
        glDeleteVertexArrays(1, &id);
    }

    void bind() const out {
        checkGlError();
    } body {
        glBindVertexArray(id);
    }

    void unbind() const out {
        checkGlError();
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
        checkGlError();
        this.unbind();
    }

    void drawElements(IndexType)(Prim prim, IndexType[] indices)
    if (is(IndexType == ubyte) || is(IndexType == ushort) || is(IndexType == uint)) {
        this.bind();
        glDrawElements(prim, indices.length, getTypeEnum!(IndexType), indices.ptr);
        checkGlError();
        this.unbind();
    }

    void drawElements(IndexType)(Prim prim, uint count)
    if (is(IndexType == ubyte) || is(IndexType == ushort) || is(IndexType == uint)) {
        this.bind();
        glDrawElements(prim, count, getTypeEnum!(IndexType), null);
        checkGlError();
        this.unbind();
    }
}
