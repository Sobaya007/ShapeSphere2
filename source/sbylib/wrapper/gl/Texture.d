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

    this(Type)(TextureTarget target, uint mipmapLevel, ImageInternalFormat iformat, uint width, uint height, ImageFormat format, Type* data) in {
        if (target == TextureTarget.Rect || target == TextureTarget.ProxyRect) {
            assert(mipmapLevel == 0);
        }
    } body {
        uint id;
        glGenTextures(1, &id);
        GlFunction.checkError();
        this.id = id;
        this.target = target;
        this.bind();
        glTexImage2D(target, mipmapLevel, iformat, width, height, 0, format, GlFunction.getTypeEnum!Type, data);
        GlFunction.checkError();
        this.setMagFilter(TextureFilter.Linear);
        this.setMinFilter(TextureFilter.Linear);
        this.setWrapS(TextureWrap.Repeat);
        this.setWrapT(TextureWrap.Repeat);
        this.unbind();
    }

    ~this() {
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

    void bind() const out {
        GlFunction.checkError();
    } body {
        glBindTexture(this.target, this.id);
    }

    void unbind() const out {
        GlFunction.checkError();
    } body{
        glBindTexture(this.target, 0);
    }

    void attachFrameBuffer(FrameBufferBindType bindType, FrameBufferAttachType attachType) out {
        GlFunction.checkError();
    } body {
        glFramebufferTexture2D(bindType, attachType, this.target, this.id, 0);
    }

    alias id this;
}
