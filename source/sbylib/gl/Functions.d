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

deprecated void lineWidth(float width) {
    glLineWidth(width);
}
