module sbylib.wrapper.gl.BufferObject;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.ObjectGL;

interface IBufferObject {
    void bind() const;
    void unbind() const;
}

class BufferObject(BufferType Type, T) : ObjectGL, IBufferObject {

    import sbylib.wrapper.gl.Functions;

    this() {
        super(GlUtils.genBuffer(), &GlUtils.deleteBuffer);
    }

    override void bind() const {
        GlFunction().bindBuffer(Type, this.id);
    }

    override void unbind() const {
        GlFunction().bindBuffer(Type, 0);
    }

    static if (is(T == struct)) {
        void sendData(T data, BufferUsage usage = BufferUsage.Static) {
            this.bind();
            GlFunction().bufferData!(T)(Type, T.sizeof, &data, usage);
            this.unbind();
        }
    } else {
        void sendData(S)(S[] data, BufferUsage usage = BufferUsage.Static) {
            this.bind();
            GlFunction().bufferData!(S)(Type, data.length * T.sizeof, data.ptr, usage);
            this.unbind();
        }
    }

    void sendSubData(T[] data) {
        this.bind();
        GlFunction().bufferSubData!(T)(Type, 0, data.length * T.sizeof, data.ptr);
        this.unbind();
    }

    T* map(BufferAccess access) {
        this.bind();
        auto res = GlFunction().mapBuffer(Type, access);
        this.unbind();
        return cast(T*)res;
    }

    void unmap() {
        this.bind();
        GlFunction().unmapBuffer(Type);
        this.unbind();
    }

}
