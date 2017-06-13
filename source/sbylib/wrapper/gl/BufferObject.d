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

    private immutable uint id;
    private size_t _size;

    this() {
        uint id;
        glGenBuffers(1, &id);
        this.id = id;
    }

    ~this() {
   //     glDeleteVertexArrays(1, &this.id);
    }

    size_t size() {
        return _size;
    }

    override void bind() const {
        glBindBuffer(Type, this.id);
    }

    override void unbind() const {
        glBindBuffer(Type, 0);
    }

    void sendData(T[] data, BufferUsage freq) {
        this.bind();
        glBufferData(Type, data.length * T.sizeof, cast(void*)data, freq);
        this.unbind();
        this._size = data.length;
    }

    void sendSubData(T[] data) {
        this.bind();
        glBufferSubData(Type, 0, data.length * T.sizeof, cast(void*)data);
        this.unbind();
    }

    void asAttribute(uint dim, uint location) {
        assert(1 <= dim && dim <= 4, "dimension must be 1 ~ 4. given " ~ to!string(dim));
        this.bind();
        glVertexAttribPointer(location, dim, getTypeEnum!(T), false, 0, null);
        this.unbind();
    }
}

alias VertexBuffer = BufferObject!(BufferType.Array, float);
alias IndexBuffer = BufferObject!(BufferType.ElementArray, uint);
