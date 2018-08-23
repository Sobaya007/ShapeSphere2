module sbylib.wrapper.gl.Renderbuffer;

import sbylib.wrapper.gl.ObjectGL;

class Renderbuffer : ObjectGL {

    import sbylib.wrapper.gl.Constants;
    import sbylib.wrapper.gl.Functions;

    private bool allocated;
    private int width, height;
    private ImageInternalFormat format;

    this() {
        super(GlUtils.genRenderbuffer(),
                &GlUtils.deleteRenderbuffer);
    }

    this(uint width, uint height, ImageInternalFormat format) {
        this();
        this.allocate(width, height, format);
    }

    void bind() {
        GlFunction().bindRenderbuffer(this.id);
    }

    void unbind() {
        GlFunction().bindRenderbuffer(0);
    }

    void allocate(uint width, uint height, ImageInternalFormat format) {
        this.bind();
        GlFunction().renderbufferStorage(width, height, format);
        this.unbind();
        this.width = width;
        this.height = height;
        this.format = format;
        this.allocated = true;
    }

    void reallocate(int width, int height) 
        in(this.allocated)
    {
        this.allocate(width, height, this.format);
    }

    Renderbuffer clone() {
        return new Renderbuffer(this.width, this.height, this.format);
    }

    void attachFramebuffer(FramebufferBindType bindType, FramebufferAttachType attachType)
        in(this.allocated)
    {
        this.bind();
        GlFunction().framebufferRenderbuffer(bindType, attachType, this.id);
       this.unbind();
    }

    void detachFramebuffer(FramebufferBindType bindType, FramebufferAttachType attachType)
        in(this.allocated)
    {
        this.bind();
        GlFunction().framebufferRenderbuffer(bindType, attachType, 0);
       this.unbind();
    }
}
