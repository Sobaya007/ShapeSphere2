module sbylib.wrapper.gl.Functions;

import sbylib.math, sbylib.wrapper.gl;
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

deprecated void lineWidth(float width) {
    glLineWidth(width);
}
