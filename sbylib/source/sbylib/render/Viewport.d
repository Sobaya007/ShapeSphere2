module sbylib.render.Viewport;

import sbylib.core.Window;
import sbylib.wrapper.gl.Functions;

interface IViewport {
    int getX() const;
    int getY() const;
    uint getWidth() const;
    uint getHeight() const;

    final void set() {
        GlFunction().setViewport(getX(), getY(), getWidth(), getHeight());
    }
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

class AspectFixViewport : IViewport {

    private int x, y;
    private uint w, h;
    private float aspect;
    private Window window;

    this(Window window) {
        this(window, cast(float)window.width / window.height);
    }

    this(Window window, float aspect) {
        this.window = window;
        this.aspect = aspect;

        this.window.addResizeCallback(&onResize);
        this.onResize();
    }

    private void onResize() {
        auto w = this.window.width;
        auto h = this.window.height;
        if(w > h * this.aspect) { //width is too big
            w = cast(uint)(h * this.aspect);
        } else { //height is too big
            h = cast(uint)(w / this.aspect);
        }
        auto x = (this.window.width - w) / 2;
        auto y = (this.window.height - h) / 2;

        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
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

class AutoFitViewport : IViewport {
    
    import sbylib.core.Core;

    private Window window;

    this(Window window = Core().getWindow()) {
        this.window = window;
    }

    override int getX() const {
        return 0;
    }
    override int getY() const {
        return 0;
    }
    override uint getWidth() const {
        return window.width;
    }
    override uint getHeight() const {
        return window.height;
    }
}
