module sbylib.gl.VertexBufferObject;

import sbylib.gl;
import derelict.opengl;

class VertexBufferObject(T) {

    private immutable {
        uint id;
        int length;
        GpuSendFrequency freq;
    }

    this(T[] data, GpuSendFrequency frequency) {
        uint id;
        glGenBuffers(1, &id);
        this.id = id;
        this.freq = frequency;
        glBindBuffer(GL_ARRAY_BUFFER, id);
        glBufferData(GL_ARRAY_BUFFER, data.length * T.sizeof, cast(void*)data, freq);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        length = cast(int)data.length;
    }

    ~this() {
        glDeleteBuffers(1, &id);
    }

@nogc:

    void bind() {
        glBindBuffer(GL_ARRAY_BUFFER, id);
    }

    void unBind() {
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }

    void update(int S = 0)(T[] data) {
        glBindBuffer(GL_ARRAY_BUFFER, id);
        foreach (d; data) {
            assert(d !is float.nan, "data includes NaN.");
        }
        glBufferSubData(GL_ARRAY_BUFFER, 0, data.length * T.sizeof, cast(void*)data);

        //T* ptr = cast(T*)glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
        //if (ptr) {
        //    foreach (i; 0..length) {
        //        ptr[i] = data[i];
        //    }
        //
        //}
        //glUnmapBuffer(GL_ARRAY_BUFFER);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
    }

    void update(int S)(Vector!(T, S)[] vertex) {
        T[] array;
        foreach (v; vertex) array ~= vertex.array;
        update(array);
    }

    alias id this;
}

alias VertexBufferObject!float VBO;
