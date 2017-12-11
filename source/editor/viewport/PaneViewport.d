module editor.viewport.PaneViewport;

import sbylib;

class PaneViewport : IViewport {

    private uint x, y, width, height;
    private float rateX, rateY, rateWidth, rateHeight;
    private Window window;
    private OrthoCamera camera;

    // @param rateX, rateY, rateWidth, rateHeight: windowの大きさに対する割合
    this(Window window, OrthoCamera camera, float rateX, float rateY, float rateWidth, float rateHeight) in {
        assert(0 <= rateX      && rateX      <= 1);
        assert(0 <= rateY      && rateY      <= 1);
        assert(0 <= rateWidth  && rateWidth  <= 1);
        assert(0 <= rateHeight && rateHeight <= 1);
    } body {

        this.window = window;
        this.camera = camera;
        this.rateX = rateX;
        this.rateY = rateY;
        this.rateWidth = rateWidth;
        this.rateHeight = rateHeight;

        float windowWidth  = cast(float)this.window.getWidth();
        this.width = cast(uint) (windowWidth  * this.rateWidth);
        this.camera.width  = this.width;
        this.x = cast(uint) (windowWidth * this.rateX);

        float initWindowHeight = cast(float)this.window.getHeight();
        this.height = cast(uint) (initWindowHeight * this.rateHeight);
        this.camera.height = this.height;

        this.window.addResizeCallback(() {
            float windowHeight = cast(float)this.window.getHeight();
            this.y = cast(uint) (initWindowHeight * this.rateY - initWindowHeight + windowHeight);
            this.camera.getObj.pos = vec3(this.width/2, this.height/2, 0);
        });
    }

    override void set() {
        GlFunction.setViewport(x, y, width, height);
    }

    override uint getX() {
        return this.x;
    }
    override uint getY() {
        return this.y;
    }
    override uint getWidth() {
        return this.width;
    }
    override uint getHeight() {
        return this.height;
    }


}
