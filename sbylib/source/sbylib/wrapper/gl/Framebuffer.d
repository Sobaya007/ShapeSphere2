module sbylib.wrapper.gl.Framebuffer;

import sbylib.wrapper.gl.ObjectGL;

immutable Framebuffer DefaultFramebuffer = new immutable Framebuffer(true);

class Framebuffer : ObjectGL {

    import sbylib.wrapper.gl.Constants;
    import sbylib.wrapper.gl.Functions;

    private immutable this(bool b) {
        super(0);
    }

    this() {
        super(GlUtils.genFramebuffer());
    }

    override void destroy() {
        super.destroy();
        GlUtils.deleteFramebuffer(id);
    }

    void bind(FramebufferBindType type) const
        in(isAlive)
    {
        GlFunction.bindFramebuffer(type, this.id);
    }

    void unbind(FramebufferBindType type) const
        in(isAlive)
    {
        GlFunction.bindFramebuffer(type, 0);
    }

    void blitsTo(const Framebuffer dst, int srcX0, int srcY0, int srcX1, int srcY1, int dstX0, int dstY0, int dstX1, int dstY1, TextureFilter filter, BufferBit[] bit...) const
    in {
        import std.algorithm : canFind;
        if (bit.canFind(BufferBit.Depth) || bit.canFind(BufferBit.Stencil)) {
            assert(filter == TextureFilter.Nearest);
        }
    }
    do {
        import std.algorithm;
        this.bind(FramebufferBindType.Read);
        dst.bind(FramebufferBindType.Write);
        GlFunction.blitFramebuffer(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, filter, bit);
        dst.unbind(FramebufferBindType.Write);
        this.unbind(FramebufferBindType.Read);
    }
}
