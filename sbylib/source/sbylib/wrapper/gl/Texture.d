module sbylib.wrapper.gl.Texture;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.ObjectGL;

class TextureBuilder {
    import sbylib.utils;
    mixin Singleton;

    TextureTarget target;
    uint mipmapLevel;
    ImageInternalFormat iformat;
    ImageFormat format;
    uint width, height;

    this() {
        this.target = TextureTarget.Tex2D;
        this.mipmapLevel = 0;
        this.iformat = ImageInternalFormat.RGBA;
        this.format = ImageFormat.RGBA;
    }

    Texture build(Type)(Type[] data) {
        return new Texture(this.target, this.mipmapLevel, this.iformat, width, height, this.format, data.ptr);
    }

    Texture build(Type)() {
        return build((Type[]).init);
    }

    Texture build() {
        return build!ubyte;
    }
}

class Texture : ObjectGL {

    import sbylib.wrapper.gl.Functions;

    private TextureTarget target;
    private bool allocated;

    private uint mWidth, mHeight;
    private ImageFormat mFormat;
    private ImageInternalFormat mInternalFormat;
    private void delegate(int level, uint width, uint height, void* data) allocateFunction;

    this(TextureTarget target) {
        super(GlUtils.genTexture(),
                &GlUtils.deleteTexture);
        this.target = target;
        this.setMagFilter(TextureFilter.Linear);
        this.setMinFilter(TextureFilter.Linear);
        this.setWrapS(TextureWrap.Repeat);
        this.setWrapT(TextureWrap.Repeat);
    }

    this(Type)(TextureTarget target, uint mipmapLevel, ImageInternalFormat iformat, uint width, uint height, ImageFormat format, Type* data) {
        this(target);
        this.allocate(mipmapLevel, iformat, width, height, format, data);
    }

    void allocate(Type)(uint mipmapLevel, ImageInternalFormat iformat, uint width, uint height, ImageFormat format, Type* data) 
    in {
        if (this.target == TextureTarget.Rect || this.target == TextureTarget.ProxyRect) {
            assert(mipmapLevel == 0);
        }
    }
    do {
        this.mWidth = width;
        this.mHeight = height;
        this.mFormat = format;
        this.mInternalFormat = iformat;
        this.allocated = true;
        this.allocateFunction = (int level, uint width, uint height, void* data) {
            GlFunction().texImage2D!(Type)(this.target, level, this.mInternalFormat, width, height, 0, this.mFormat, cast(Type*)data);
        };
        this.bind();
        this.allocateFunction(mipmapLevel, width, height, data);
        this.unbind();
    }

    void reallocate(uint mipmapLevel, uint width, uint height) 
        in(allocated)
    {
        this.mWidth = width;
        this.mHeight = height;
        this.bind();
        this.allocateFunction(mipmapLevel, width, height, null);
        this.unbind();
    }

    Texture clone(int level=0) {
        auto result =  new Texture(this.target);
        result.mWidth = this.width;
        result.mHeight = this.height;
        result.mFormat = this.mFormat;
        result.mInternalFormat = this.mInternalFormat;
        result.allocated = true;
        result.allocateFunction = this.allocateFunction;
        result.bind();
        result.allocateFunction(level, width, height, null);
        result.unbind();
        return result;
    }

    void update(Type)(uint mipmapLevel, Type *data) {
        update(mipmapLevel, 0, 0, this.mWidth, this.mHeight, this.mFormat, data);
    }

    void update(Type)(uint mipmapLevel, int offsetX, int offsetY, uint width, uint height, ImageFormat iformat, Type *data) {
        this.bind();
        import std.algorithm;
        offsetX = max(0, offsetX);
        offsetY = max(0, offsetY);
        width  = min(width,  this.width  - offsetX);
        height = min(height, this.height - offsetY);
        GlFunction().texSubImage2D!(Type)(this.target, mipmapLevel, offsetX, offsetY, width, height, this.mFormat, data);
        this.unbind();
    }

    void setMagFilter(TextureFilter type) {
        this.setParameter(TextureParamName.MagFilter, type);
    }

    void setMinFilter(TextureFilter type) {
        this.setParameter(TextureParamName.MinFilter, type);
    }

    void setWrapS(TextureWrap type) {
        this.setParameter(TextureParamName.WrapS, type);
    }

    void setWrapT(TextureWrap type) {
        this.setParameter(TextureParamName.WrapT, type);
    }

    private void setParameter(T)(TextureParamName pname, T value) {
        this.bind();
        GlFunction().texParameter!(T)(this.target, pname, value);
        this.unbind();
    }

    void bind() const {
        GlFunction().bindTexture(this.target, this.id);
    }

    void unbind() const {
        GlFunction().bindTexture(this.target, 0);
    }

    void bindForCompute(uint unit, uint level, bool layered, uint layer, BufferAccess access) {
        GlFunction().bindImageTexture(unit, this.id, level, layered, layer, access, this.mInternalFormat);
    }

    void attachFramebuffer(FramebufferBindType bindType, FramebufferAttachType attachType)
        in(this.allocated)
    {
        this.bind();
        GlFunction().framebufferTexture2D(bindType, attachType, this.target, this.id, 0);
        this.unbind();
    }

    void detachFramebuffer(FramebufferBindType bindType, FramebufferAttachType attachType)
        in(this.allocated)
    {
        this.bind();
        GlFunction().framebufferTexture2D(bindType, attachType, this.target, 0, 0);
        this.unbind();
    }

    void blitsTo(T)(T* result, ImageFormat format, int level = 0) 
        in(this.allocated)
    {
        this.bind();
        GlFunction().getTexImage!(T)(this.target, level, format, result);
        this.unbind();
    }

    import sbylib.render.RenderTarget;
    void blitsTo(IRenderTarget dst) {
        import sbylib.utils.Functions : blitsTo;
        blitsTo(this, dst);
    }

    static void activate(uint unit) {
        GlFunction().activeTexture(unit);
    }

    int width() {
        return mWidth;
    }

    int height() {
        return mHeight;
    }

    ImageInternalFormat internalFormat() {
        return mInternalFormat;
    }

    void depthStencilMode(DepthStencilMode mode) {
        this.setParameter(TextureParamName.DepthStencilMode, mode);
    }

    override string toString() const {
        import std.format;
        return format!("Texture(%d)")(this.id);
    }
}
