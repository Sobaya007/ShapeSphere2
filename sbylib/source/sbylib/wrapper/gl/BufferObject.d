module sbylib.wrapper.gl.BufferObject;

public import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;

interface BufferObject(BufferType Type) {
    void bind() const;
    void unbind() const;
}

class BufferObject(BufferType Type, T) : BufferObject!Type {

    import derelict.opengl;

    protected immutable uint id;
    private bool alive = true;

    this() out {
        GlFunction.checkError();
    } body {
        uint id;
        glGenBuffers(1, &id);
        this.id = id;
        GlFunction.checkError();
    }

    ~this() {
        //assert(!alive);
        import std.stdio;
        if (alive) writeln("Invalid Destruction For BufferObject");
    }

    void destroy() in {
        assert(alive);
    } out {
        GlFunction.checkError();
    } body {
        this.alive = false;
        glDeleteVertexArrays(1, &this.id);
    }


    override void bind() const in {
        assert(alive);
    } out {
        GlFunction.checkError();
    } body {
        glBindBuffer(Type, this.id);
    }

    override void unbind() const in {
        assert(alive);
    } out {
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
            glBufferData(Type, data.length * T.sizeof, cast(void*)data, freq);
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
