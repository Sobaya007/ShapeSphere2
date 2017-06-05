module sbylib.gl.IndexBufferObject;

import sbylib.gl;
import derelict.opengl;

class IndexBufferObject(T) {

    immutable uint id;
    immutable int length;
    immutable GpuSendFrequency freq;

    this(T[] data, GpuSendFrequency frequency) {
        uint id;
        glGenBuffers(1, &id);
        this.id = id;
        this.freq = frequency;
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, data.length * T.sizeof, cast(void*)data, freq);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        length = cast(int)data.length;
    }

    ~this() {
        glDeleteBuffers(1, &id);
    }

@nogc:

    void bind() const {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
    }

    void unBind() const {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }

    void update(T[] data) {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, id);
        T* ptr = cast(T*)glMapBuffer(GL_ELEMENT_ARRAY_BUFFER, GL_WRITE_ONLY);
        if (ptr) {
            foreach (i; 0..length) {
                ptr[i] = data[i];
            }
        }
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    }

    alias id this;
}

alias IndexBufferObject!uint IBO;
