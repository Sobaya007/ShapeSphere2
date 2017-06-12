module sbylib.wrapper.gl.BufferObject;

import derelict.opengl;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;

interface BufferObject(BufferType Type) {
    void bind();
    void unbind();
}

class BufferObject(BufferType Type, T) : BufferObject!Type {

    private immutable uint id;

    this() {
        uint id;
        glGenBuffers(1, &id);
        this.id = id;
    }

    ~this() {
        glDeleteVertexArrays(1, &this.id);
    }

    override void bind() {
        glBindBuffer(Type, this.id);
    }

    override void unbind() {
        glBindBuffer(Type, 0);
    }

    void sendData(T[] data, BufferUsage freq) {
        this.bind();
        glBufferData(Type, data.length * T.sizeof, cast(void*)data, freq);
        this.unbind();
    }

    void sendSubData(T[] data) {
        this.bind();
        glBufferSubData(Type, 0, data.length * T.sizeof, cast(void*)data);
        this.unbind();
    }

    void asAttribute(uint dim, uint location) {
        assert(1 <= dim && dim <= 4);
        this.bind();
        glVertexAttribPointer(location, dim, getTypeEnum!(T), false, cast(int)(dim * float.sizeof), null);
        this.unbind();
    }
}

alias VertexBuffer = BufferObject!(BufferType.Array, float);
alias IndexBuffer = BufferObject!(BufferType.ElementArray, uint);
