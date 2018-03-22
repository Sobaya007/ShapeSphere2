module editor.viewport.PaneViewport;

import sbylib;

class PaneViewport : IViewport {

    private int x, y;
    private uint width, height;
    private float rateX, rateY, rateWidth, rateHeight;
    private Window window;
    private OrthoCamera camera;

    // @param rateX, rateY, rateWidth, rateHeight: windowの大きさに対する割合
    this(Window window, OrthoCamera camera, int x, int y, uint width, uint height) in {

    } body {

        this.window = window;
        this.camera = camera;

        this.width = width;
        this.camera.width  = this.width;
        this.x = x;

        this.height = height;
        this.camera.height = this.height;

        int initWindowHeight = this.window.getHeight();
        int initY = y;

        this.window.addResizeCallback(() {
            import std.conv;
            int windowHeight = this.window.getHeight();
            this.y = initY + windowHeight - initWindowHeight;
            this.camera.obj.pos = vec3(this.width/2, this.height/2, 0);
        });
    }

    override void set() {
        GlFunction.setViewport(x, y, width, height);
    }

    override int getX() const {
        return this.x;
    }
    override int getY() const {
        return this.y;
    }
    override uint getWidth() const {
        return this.width;
    }
    override uint getHeight() const {
        return this.height;
    }


}
