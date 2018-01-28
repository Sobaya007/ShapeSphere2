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
        GlFunction.checkError();
    } body {
        uint id;
        glGenBuffers(1, &id);
        this.id = id;
        GlFunction.checkError();
    }

    ~this() out {
        GlFunction.checkError();
    } body {
        glDeleteVertexArrays(1, &this.id);
    }


    override void bind() const out {
        GlFunction.checkError();
    } body {
        glBindBuffer(Type, this.id);
    }

    override void unbind() const out {
        GlFunction.checkError();
    } body {
        glBindBuffer(Type, 0);
        GlFunction.checkError();
    }

    static if (is(T == struct)) {
        void sendData(T data, BufferUsage freq = BufferUsage.Static) {
            this.bind();
            glBufferData(Type, T.sizeof, &data, freq);
            GlFunction.checkError();
            this.unbind();
        }
    } else {
        void sendData(S)(S data, BufferUsage freq = BufferUsage.Static) {
            this.bind();
            //import std.stdio, std.datetime.stopwatch;
            //writeln("Type = ", Type.stringof);
            //writeln("T = ", T.stringof);
            //writeln("S = ", S.stringof);
            //writeln("length = ", data.length);
            //writeln("size = ", T.sizeof);
            //writeln("total = ", data.length * T.sizeof);
            //writeln("freq = ", freq);
            //StopWatch sw;
            //sw.start();
            glBufferData(Type, data.length * T.sizeof, cast(void*)data, freq);
            //writeln("time = ", sw.peek);
            GlFunction.checkError();
            this.unbind();
        }
    }

    void sendSubData(T[] data) {
        this.bind();
        glBufferSubData(Type, 0, data.length * T.sizeof, cast(void*)data);
        GlFunction.checkError();
        this.unbind();
    }

    T* map(BufferAccess access) {
        this.bind();
        auto res = glMapBuffer(Type, access);
        GlFunction.checkError();
        this.unbind();
        return cast(T*)res;
    }

    void unmap() {
        this.bind();
        glUnmapBuffer(Type);
        GlFunction.checkError();
        this.unbind();
    }

}
