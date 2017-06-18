module sbylib.wrapper.gl.Viewport;

import derelict.opengl;

class Viewport {
    private uint x, y, w, h;

    this(uint x, uint y, uint w, uint h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    void set() {
        glViewport(x,y,w,h);
    }
}
