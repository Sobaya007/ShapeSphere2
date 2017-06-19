module sbylib.wrapper.gl.Functions;

import sbylib.math, sbylib.wrapper.gl;
import std.algorithm;
import derelict.opengl;

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

void clear(ClearMode[] mode...) {
    glClear(reduce!((a,b)=>a|b)(mode));
}

void clearColor(vec4 color) {
    glClearColor(color.x, color.y, color.z, color.w);
}

void clearStencil(int stencil) {
    glClearStencil(stencil);
}

void captureScreen(Texture tex, int left, int bottom, int width, int height) {
    tex.bind;
    //glCopyTexImage2D(GL_TEXTURE_2D,0, tex.type, left, bottom, width, height, 0);
    //tex.setWrapS(Texture.TexWrapType.ClampToEdge);
    //tex.setWrapT(Texture.TexWrapType.ClampToEdge);
    tex.unbind;
}

void enable(Capability cap) {
    glEnable(cap);
}

void disable(Capability cap) {
    glDisable(cap);
}

void depthFunc(TestFunc func) {
    enable(Capability.DepthTest);
    glDepthFunc(func);
}

void faceSetting(PolygonMode polygon, FaceMode face = FaceMode.FrontBack) {
    if (polygon == PolygonMode.None) {
        assert(face == FaceMode.FrontBack);
        glEnable(Capability.CullFace);
        glCullFace(FaceMode.FrontBack);
    } else {
        final switch (face) {
        case FaceMode.FrontBack:
            glDisable(Capability.CullFace);
            glPolygonMode(face, polygon);
            break;
        case FaceMode.Front:
            glEnable(Capability.CullFace);
            glCullFace(FaceMode.Back);
            glPolygonMode(face, polygon);
            break;
        case FaceMode.Back:
            glEnable(Capability.CullFace);
            glCullFace(FaceMode.Front);
            glPolygonMode(face, polygon);
            break;
        }
    }
}

void stencil(TestFunc test, uint reffer, uint mask, StencilWrite sfail, StencilWrite dpfail, StencilWrite pass) {
    enable(Capability.StencilTest);
    glStencilFunc(test, reffer, mask);
    glStencilOp(sfail, dpfail, pass);
}

void blendFunc(BlendFactor src, BlendFactor dst) {
    enable(Capability.Blend);
    glBlendFunc(src, dst);
}

void blendEquation(BlendEquation eq) {
    enable(Capability.Blend);
    glBlendEquation(eq);
}

deprecated void lineWidth(float width) {
    glLineWidth(width);
}
