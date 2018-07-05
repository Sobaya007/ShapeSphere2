module sbylib.wrapper.gl.Texture;

import derelict.opengl;
import derelict.freeimage.freeimage;
import std.stdio, std.string, std.conv;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.freeimage.Image;

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

class Texture {

    immutable uint id;
    private immutable TextureTarget target;
    private bool alive = true;
    private bool allocated;

    private uint mWidth, mHeight;
    private ImageFormat mFormat;
    private ImageInternalFormat mInternalFormat;

    this(TextureTarget target) {
        uint id;
        glGenTextures(1, &id);
        GlFunction.checkError();
        this.id = id;
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

    ~this() {
        import std.stdio;
        if (alive) writeln("Invalid Destruction For Texture");
    }

    void allocate(Type)(uint mipmapLevel, ImageInternalFormat iformat, uint width, uint height, ImageFormat format, Type* data) in {
        if (this.target == TextureTarget.Rect || this.target == TextureTarget.ProxyRect) {
            assert(mipmapLevel == 0);
        }
    } body {
        this.bind();
        glTexImage2D(this.target, mipmapLevel, iformat, width, height, 0, format, GlFunction.getTypeEnum!Type, data);
        GlFunction.checkError();
        this.unbind();
        this.allocated = true;
        this.mWidth = width;
        this.mHeight = height;
        this.mFormat = format;
        this.mInternalFormat = iformat;
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
        glTexSubImage2D(this.target, mipmapLevel, offsetX, offsetY, width, height, iformat, GlFunction.getTypeEnum!Type, data);
        GlFunction.checkError();
        this.unbind();
    }

    void destroy() in {
        assert(alive);
    } out {
        GlFunction.checkError();
    } body {
        alive = false;
        glDeleteTextures(1, &id);
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
        glTexParameteri(this.target, pname, value);
        GlFunction.checkError();
        this.unbind();
    }

    void bind() const in {
        assert(alive);
    } out {
        GlFunction.checkError();
    } body {
        glBindTexture(this.target, this.id);
    }

    void unbind() const in {
        assert(alive);
    } out {
        GlFunction.checkError();
    } body{
        glBindTexture(this.target, 0);
    }

    void bindForCompute(uint unit, uint level, bool layered, uint layer, BufferAccess access) in {
        assert(unit < GL_MAX_IMAGE_UNITS);
    } out {
        GlFunction.checkError();
    } body {
        glBindImageTexture(unit, this.id, level, layered, layer, access, this.mInternalFormat);
    }

    void attachFrameBuffer(FrameBufferBindType bindType, FrameBufferAttachType attachType) in {
        assert(this.allocated);
    } out {
        GlFunction.checkError();
    } body {
        this.bind();
        glFramebufferTexture2D(bindType, attachType, this.target, this.id, 0);
        this.unbind();
    }

    void blitsTo(T)(T* result, ImageFormat format, int level = 0) in {
        assert(this.allocated);
    } body {
        this.bind();
        glGetTexImage(this.target, level, format, GlFunction.getTypeEnum!(T), result);
        this.unbind();
    }

    import sbylib.render.RenderTarget;
    void blitsTo(IRenderTarget dst) {
        import sbylib.utils.Functions : blitsTo;
        blitsTo(this, dst);
    }

    static void activate(uint unit) out {
        GlFunction.checkError();
    } do {
        glActiveTexture(GL_TEXTURE0 + unit);
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
        return format!("Texture(%d)")(this.id);
    }

    alias id this;
}
