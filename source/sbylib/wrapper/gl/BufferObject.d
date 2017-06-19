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

    this() {
        uint id;
        glGenBuffers(1, &id);
        this.id = id;
    }

    ~this() {
   //     glDeleteVertexArrays(1, &this.id);
    }


    override void bind() const {
        glBindBuffer(Type, this.id);
    }

    override void unbind() const {
        glBindBuffer(Type, 0);
    }

    void sendData(T[] data, BufferUsage freq = BufferUsage.Static) {
        this.bind();
        glBufferData(Type, data.length * T.sizeof, cast(void*)data, freq);
        this.unbind();
    }

    void sendData(S)(S data, BufferUsage freq = BufferUsage.Static) if (is(S == struct)) {
        import std.stdio;
        writeln(S.stringof);
        writeln(S.sizeof);
        this.bind();
        glBufferData(Type, S.sizeof, cast(void*)&data, freq);
        this.unbind();
    }

    void sendSubData(T[] data) {
        this.bind();
        glBufferSubData(Type, 0, data.length * T.sizeof, cast(void*)data);
        this.unbind();
    }
}
