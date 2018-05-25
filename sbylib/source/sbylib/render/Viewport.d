module sbylib.render.Viewport;

import sbylib.core.Window;
import sbylib.wrapper.gl.Functions;

interface IViewport {
    void set();
    int getX() const;
    int getY() const;
    uint getWidth() const;
    uint getHeight() const;
}

class Viewport : IViewport {
    private int x,y;
    private uint w,h;

    this(int x, int y, uint w, uint h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    void setSize(uint w, uint h) {
        this.w = w;
        this.h = h;
    }

    override void set() {
        GlFunction.setViewport(x,y,w,h);
    }

    override int getX() const {
        return this.x;
    }
    override int getY() const {
        return this.y;
    }
    override uint getWidth() const{
        return this.w;
    }
    override uint getHeight() const {
        return this.h;
    }
}

class AutomaticViewport : IViewport {

    private int x, y;
    uint w, h;
    private float aspect;
    private Window window;

    this(Window window) {
        this(window, cast(float)window.getWidth() / window.getHeight());
    }

    this(Window window, float aspect) {
        this.window = window;
        this.aspect = aspect;

        this.window.addResizeCallback(&onResize);
        this.onResize();
    }

    private void onResize() {
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
    }

    override void set() {
        GlFunction.setViewport(x,y,w,h);
    }

    override int getX() const {
        return this.x;
    }
    override int getY() const {
        return this.y;
    }
    override uint getWidth() const {
        return this.w;
    }
    override uint getHeight() const {
        return this.h;
    }
}
