module sbylib.wrapper.gl.FrameBuffer;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import derelict.opengl;

immutable FrameBuffer DefaultFrameBuffer = new immutable FrameBuffer(true);

class FrameBuffer {

    private immutable uint id;

    private immutable this(bool b) {
        this.id = 0;
    }

    this() out {
        GlFunction.checkError();
    } body {
        uint id;
        glGenFramebuffers(1, &id);
        this.id = id;
    }

    ~this() out {
        GlFunction.checkError();
    } body {
        glDeleteBuffers(1, &id);
    }

    void bind(FrameBufferBindType type) const out {
        GlFunction.checkError();
    } body {
        glBindFramebuffer(type, this.id);
    }

    void unbind(FrameBufferBindType type) const out {
        GlFunction.checkError();
    } body {
        glBindFramebuffer(type, 0);
    }

    void blitsTo(const FrameBuffer dst, int srcX0, int srcY0, int srcX1, int srcY1, int dstX0, int dstY0, int dstX1, int dstY1, TextureFilter filter, BufferBit[] bit...) const {
        import std.algorithm;
        this.bind(FrameBufferBindType.Read);
        dst.bind(FrameBufferBindType.Write);
        glBlitFramebuffer(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, bit.reduce!((a,b)=>a|b), filter);
        dst.unbind(FrameBufferBindType.Write);
        this.unbind(FrameBufferBindType.Read);
    }
}
