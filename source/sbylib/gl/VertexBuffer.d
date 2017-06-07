module sbylib.gl.Buffer;

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

    void sendData(T)(T[] data, GpuSendFrequency freq) {
        glBufferData(this.type, data.length * T.sizeof, cast(void*)data, freq);
    }

    void sendSubData(T)(T[] data) {
        glBufferSubData(this.type, 0, data.length * T.sizeof, cast(void*)data);
    }
}

class VertexBuffer : BufferObject {
    this() {
        super(BufferType.Array);
    }
}

class IndexBuffer : BufferObject {
    this() {
        super(BufferType.ElementArray);
    }
}
