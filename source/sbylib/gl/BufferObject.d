module sbylib.gl.BufferObject;

import derelict.opengl;
import sbylib.gl.Constants;

class BufferObject {

    private immutable uint id;
    private immutable BufferType type;

    this(BufferType type) {
        uint id;
        glGenBuffers(1, &id);
        this.id = id;
        this.type = type;
    }

    ~this() {
        glDeleteVertexArrays(1, &this.id);
    }

    void bind() {
        glBindBuffer(this.type, this.id);
    }

    void unbind() {
        glBindBuffer(this.type, 0);
    }

    void sendData(T)(T[] data, BufferUsage freq) {
        this.bind();
        glBufferData(this.type, data.length * T.sizeof, cast(void*)data, freq);
        this.unbind();
    }

    void sendSubData(T)(T[] data) {
        this.bind();
        glBufferSubData(this.type, 0, data.length * T.sizeof, cast(void*)data);
        this.unbind();
    }

    void asAttribute(uint location, uint dim) {
        this.bind();
        glVertexAttribPointer(location, dim, GL_FLOAT, GL_FALSE, cast(int)(dim * float.sizeof), null);
        this.unbind();
    }
}
