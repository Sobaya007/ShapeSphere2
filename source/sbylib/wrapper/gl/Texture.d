module sbylib.wrapper.gl.Texture;

import derelict.opengl;
import derelict.freeimage.freeimage;
import std.stdio, std.string, std.conv;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.freeimage.Image;

class Texture {

    immutable uint id;
    private immutable TextureTarget target;
    private bool alive = true;
    private bool allocated;

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
        assert(!alive);
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
    }

    void update(Type)(uint mipmapLevel, int offsetX, int offsetY, uint width, uint height, ImageFormat format, Type *data) {
        this.bind();
        glTexSubImage2D(this.target, mipmapLevel, offsetX, offsetY, width, height, format, GlFunction.getTypeEnum!Type, data);
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

    void attachFrameBuffer(FrameBufferBindType bindType, FrameBufferAttachType attachType) in {
        assert(this.allocated);
    } out {
        GlFunction.checkError();
    } body {
        this.bind();
        glFramebufferTexture2D(bindType, attachType, this.target, this.id, 0);
        this.unbind();
    }

    alias id this;
}
