module sbylib.render.Viewport;

import sbylib.core.Window;
import sbylib.wrapper.gl.Functions;

interface IViewport {
    void set();
}

class Viewport : IViewport {
    private uint x,y,w,h;

    this(uint x, uint y, uint w, uint h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    override void set() {
        GlFunction.setViewport(x,y,w,h);
    }
}

class AutomaticViewport : IViewport {

    private uint x, y, w, h;
    private float aspect;
    private Window window;

    this(Window window) {
        this(window, cast(float)window.getWidth() / window.getHeight());
    }

    this(Window window, float aspect) {
        this.window = window;
        this.aspect = aspect;

        this.window.addResizeCallback(() {
            auto w = this.window.getWidth();
            auto h = this.window.getHeight();
            if(w > h * this.aspect) { //width is too big
                w = cast(uint)(h * this.aspect);
            } else { //height is too big
                h = cast(uint)(w / this.aspect);
            }
            auto x = (this.window.getWidth() - w) / 2;
            auto y = (this.window.getHeight() - h) / 2;

            this.x = x;
            this.y = y;
            this.w = w;
            this.h = h;
        });
    }

    override void set() {
        GlFunction.setViewport(x,y,w,h);
    }
}
