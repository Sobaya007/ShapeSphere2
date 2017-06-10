module sbylib.gl.Functions;

import sbylib.math, sbylib.gl;
import std.algorithm;
import derelict.opengl;

enum ClearMode {Color = GL_COLOR_BUFFER_BIT, Depth = GL_DEPTH_BUFFER_BIT, Stencil = GL_STENCIL_BUFFER_BIT};

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
    glCopyTexImage2D(GL_TEXTURE_2D,0, tex.type, left, bottom, width, height, 0);
    tex.setWrapS(Texture.TexWrapType.ClampToEdge);
    tex.setWrapT(Texture.TexWrapType.ClampToEdge);
    tex.unBind;
}

template getTypeEnum(T) {
    static if (is(T == ubyte)) enum getTypeEnum = GLType.Ubyte;
    else static if (is(T == byte)) enum getTypeEnum = GLType.Byte;
    else static if (is(T == ushort)) enum getTypeEnum = GLType.Ushort;
    else static if (is(T == short)) enum getTypeEnum = GLType.Short;
    else static if (is(T == uint)) enum getTypeEnum = GLType.Uint;
    else static if (is(T == int)) enum getTypeEnum = GLType.Int;
    else static if (is(T == float)) enum getTypeEnum = GLType.Float;
    else static if (is(T == double)) enum getTypeEnum = GLType.Double;
    else static assert(false, T.stringof ~ " is an invalid type.");
}

void drawElements(IndexType)(Prim prim, IndexType[] indices)
if (is(IndexType == ubyte) || is(IndexType == ushort) || is(IndexType == uint)) {
    glDrawElements(prim, indices.length, getTypeEnum(IndexType), indices.ptr);
}

void drawElements(IndexType)(Prim prim, uint indicesCount, BufferObject!(BufferType.ElementArray, IndexType) indices)
if (is(IndexType == ubyte) || is(IndexType == ushort) || is(IndexType == uint)) {
    indices.bind();
    glDrawElements(prim, indicesCount, getTypeEnum(IndexType), null);
    indices.unbind();
}

deprecated void lineWidth(float width) {
    glLineWidth(width);
}
