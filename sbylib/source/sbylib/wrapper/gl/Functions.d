module sbylib.wrapper.gl.Functions;

import sbylib.math, sbylib.wrapper.gl;
import std.algorithm, std.conv;
import derelict.opengl;
import sbylib.wrapper.glfw;

class GlFunction {

static:

    template getTypeEnum(T) {
        static if (is(T == ubyte)) enum GLType getTypeEnum = GLType.Ubyte;
        else static if (is(T == byte)) enum GLType getTypeEnum = GLType.Byte;
        else static if (is(T == ushort)) enum GLType getTypeEnum = GLType.Ushort;
        else static if (is(T == short)) enum GLType getTypeEnum = GLType.Short;
        else static if (is(T == uint)) enum GLType getTypeEnum = GLType.Uint;
        else static if (is(T == int)) enum GLType getTypeEnum = GLType.Int;
        else static if (is(T == float)) enum GLType getTypeEnum = GLType.Float;
        else static if (is(T == double)) enum GLType getTypeEnum = GLType.Double;
        else static assert(false, T.stringof ~ " is an invalid type.");
    }

    void clear(BufferBit[] mode...) out {
        checkError();
    } body {
        if (mode.canFind(ClearMode.Color)) glColorMask(true,true,true,true); //これしないとColorをClearできない
        if (mode.canFind(ClearMode.Depth)) glDepthMask(true); //これしないとDepthをClearできない
        if (mode.canFind(ClearMode.Stencil)) glStencilMask(~0); //これしないとStencilをClearできない
        glClear(reduce!((a,b)=>a|b)(mode));
    }

    void clearColor(vec4 color) out {
        checkError();
    } body {
        glClearColor(color.x, color.y, color.z, color.w);
    }

    void clearStencil(int stencil) out {
        checkError();
    } body {
        glClearStencil(stencil);
    }

    void captureScreen(Texture tex, int left, int bottom, int width, int height) {
        tex.bind;
        //glCopyTexImage2D(GL_TEXTURE_2D,0, tex.type, left, bottom, width, height, 0);
        //tex.setWrapS(Texture.TexWrapType.ClampToEdge);
        //tex.setWrapT(Texture.TexWrapType.ClampToEdge);
        tex.unbind;
    }

    void enable(Capability cap) out {
        checkError();
    } body {
        glEnable(cap);
    }

    void disable(Capability cap) out {
        checkError();
    } body {
        glDisable(cap);
    }

    void colorWrite(bool colorWrite) out {
        checkError();
    } body {
        glColorMask(colorWrite, colorWrite, colorWrite, colorWrite);
    }

    void depthTest(bool depthTest) out {
        checkError();
    } body {
        if (depthTest) {
            enable(Capability.DepthTest);
        } else {
            disable(Capability.DepthTest);
        }
    }

    void depthWrite(bool depthWrite) out {
        checkError();
    } body {
        glDepthMask(depthWrite);
    }

    void depthFunc(TestFunc func) out {
        checkError();
    } body {
        enable(Capability.DepthTest);
        glDepthFunc(func);
    }

    void faceSetting(PolygonMode polygon, FaceMode face = FaceMode.FrontBack) out {
        checkError();
    } body {
        if (polygon == PolygonMode.None) {
            assert(face == FaceMode.FrontBack);
            glEnable(Capability.CullFace);
            glCullFace(FaceMode.FrontBack);
        } else {
            final switch (face) {
            case FaceMode.FrontBack:
                //glDisable(Capability.CullFace);
                glPolygonMode(FaceMode.FrontBack, polygon);
                break;
            case FaceMode.Front:
                glEnable(Capability.CullFace);
                glCullFace(FaceMode.Back);
                glPolygonMode(FaceMode.FrontBack, polygon);
                break;
            case FaceMode.Back:
                glEnable(Capability.CullFace);
                glCullFace(FaceMode.Front);
                glPolygonMode(FaceMode.FrontBack, polygon);
                break;
            }
        }
    }

    void stencilWrite(bool stencilWrite) out {
        checkError();
    } body {
        glStencilMask(stencilWrite);
    }

    void stencil(TestFunc test, uint reffer, uint mask, StencilWrite sfail, StencilWrite dpfail, StencilWrite pass) out {
        checkError();
    } body {
        enable(Capability.StencilTest);
        glStencilFunc(test, reffer, mask);
        glStencilOp(sfail, dpfail, pass);
    }

    void blendFunc(BlendFactor src, BlendFactor dst) out {
        checkError();
    } body {
        glBlendFunc(src, dst);
    }

    void blendEquation(BlendEquation eq) out {
        checkError();
    } body {
        glBlendEquation(eq);
    }

    void setPixelPackAlign(int alignment) in {
        assert(alignment == 1
                 || alignment == 2
                 || alignment == 4
                 || alignment == 8);
    } body {
        glPixelStorei(PixelAlignType.Pack, alignment);
    }

    void setPixelUnpackAlign(int alignment) in {
        assert(alignment == 1
                 || alignment == 2
                 || alignment == 4
                 || alignment == 8);
    } body {
        glPixelStorei(PixelAlignType.Unpack, alignment);
    }

    void setViewport(uint x, uint y, uint w, uint h) out {
        checkError();
    } body {
        glViewport(x,y,w,h);
    }

    void scissor(uint x, uint y, uint width, uint height) {
        enable(Capability.ScissorTest);
        glScissor(x, y, width, height);
    }

    void dispatchCompute(uint groupNumX, uint groupNumY, uint groupNumZ) out {
        GlFunction.checkError();
    } body {
        glDispatchCompute(groupNumX, groupNumY, groupNumZ);
    }

    void checkError(string ext = "", string fileName=__FILE__) {
        debug {
            if (GLFW.hasTerminated) return;
            auto errorCode = glGetError().to!GlErrorType;
            if (errorCode == GlErrorType.NoError) return;
            if (errorCode == GlErrorType.InvalidFramebufferOperation) {
                auto status = glCheckFramebufferStatus(GL_FRAMEBUFFER).to!FramebufferStatus;
                assert(false, errorCode.to!string ~ " : " ~ status.to!string ~ "\n" ~ ext ~ " at " ~ fileName);
            } else {
                assert(false, errorCode.to!string ~ "\n" ~ ext ~ " at " ~ fileName);
            }
        }
    }

    void lineWidth(float width) out {
        checkError();
    } do {
        glLineWidth(width);
    }

    int getBitPerPixel(ImageInternalFormat iformat) {
        final switch (iformat) {
            case ImageInternalFormat.R:
                return 32;
            case ImageInternalFormat.RG:
                return 32;
            case ImageInternalFormat.RGB:
                return 32;
            case ImageInternalFormat.RGBA:
                return 32;
            case ImageInternalFormat.RGBA16F:
                return 16;
            case ImageInternalFormat.RGBA32F:
                return 32;
            case ImageInternalFormat.Depth:
                return 24;
            case ImageInternalFormat.Stencil:
                assert(false); //知らん
            case ImageInternalFormat.DepthStencil:
                assert(false); //知らん
        }
        assert(false);
    }

    float[2] getAliasedLineWidthRange() {
        return get!(float, 2)(ParamName.AliasedLineWidthRange);
    }

    float[2] getSmoothLineWidthRange() {
        return get!(float, 2)(ParamName.SmoothLineWidthRange);
    }

    auto get(T, size_t N)(ParamName param) out {
        checkError();
    } do {
        T[N] data;
        getFunction!T(param, data.ptr);
        return data;
    }

    template getFunction(T) {
        static if (is(T == int)) {
            alias getFunction = glGetIntegerv;
        } else static if (is(T == float)) {
            alias getFunction = glGetFloatv;
        } else static if (is(T == bool)) {
            alias getFunction = glGetBooleanv;
        } else {
            static assert(false);
        }
    }
}
