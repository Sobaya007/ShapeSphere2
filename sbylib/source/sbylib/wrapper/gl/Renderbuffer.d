module sbylib.wrapper.gl.Renderbuffer;

import sbylib.wrapper.gl.ObjectGL;

class Renderbuffer : ObjectGL {

    import sbylib.wrapper.gl.Constants;
    import sbylib.wrapper.gl.Functions;

    private bool allocated;

    this() {
        super(GlUtils.genRenderbuffer());
    }

    this(uint width, uint height, ImageInternalFormat format) {
        this();
        this.allocate(width, height, format);
    }

    override void destroy() {
        super.destroy();
        GlUtils.deleteRenderbuffer(this.id);
    }

    void bind() {
        GlFunction.bindRenderbuffer(this.id);
    }

    void unbind() {
        GlFunction.bindRenderbuffer(0);
    }

    void allocate(uint width, uint height, ImageInternalFormat format) {
        this.bind();
        GlFunction.renderbufferStorage(width, height, format);
        this.unbind();
        this.allocated = true;
    }

    void attachFramebuffer(FramebufferBindType bindType, FramebufferAttachType attachType)
        in(this.allocated)
    {
        this.bind();
        GlFunction.framebufferRenderbuffer(bindType, attachType, this.id);
       this.unbind();
    }
}
