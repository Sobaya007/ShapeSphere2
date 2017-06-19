module sbylib.wrapper.gl.BufferObject;

import derelict.opengl;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import std.conv;

interface BufferObject(BufferType Type) {
    void bind() const;
    void unbind() const;
}

class BufferObject(BufferType Type, T) : BufferObject!Type {

    protected immutable uint id;

    this() out {
        checkGlError();
    } body {
        uint id;
        glGenBuffers(1, &id);
        this.id = id;
        checkGlError();
    }

    ~this() out {
        checkGlError();
    } body {
        glDeleteVertexArrays(1, &this.id);
    }


    override void bind() const out {
        checkGlError();
    } body {
        glBindBuffer(Type, this.id);
    }

    override void unbind() const out {
        checkGlError();
    } body {
        glBindBuffer(Type, 0);
        checkGlError();
    }

    void sendData(T[] data, BufferUsage freq = BufferUsage.Static) {
        this.bind();
        glBufferData(Type, data.length * T.sizeof, cast(void*)data, freq);
        checkGlError();
        this.unbind();
    }

    void sendData(S)(S data, BufferUsage freq = BufferUsage.Static) if (is(S == struct)) {
        this.bind();
        glBufferData(Type, S.sizeof, &data, freq);
        checkGlError();
        this.unbind();
    }

    void sendSubData(T[] data) {
        this.bind();
        glBufferSubData(Type, 0, data.length * T.sizeof, cast(void*)data);
        checkGlError();
        this.unbind();
    }

    void* map(BufferAccess access) {
        this.bind();
        auto res = glMapBuffer(Type, access);
        checkGlError();
        this.unbind();
        return res;
    }

    void unmap() {
        this.bind();
        glUnmapBuffer(Type);
        checkGlError();
        this.unbind();
    }

}
