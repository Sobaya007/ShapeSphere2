module editor.viewport.ViewerViewport;

import sbylib;

class ViewerViewport : IViewport {

    private int x, y;
    private uint width, height;
    private float aspect;

    this(int x, int y, uint width, uint height) {
        this(x, y, width, height, width / cast(float)height);
    }

    this(int x, int y, uint width, uint height, float aspect) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.aspect = aspect;
    }

    override void set() {
        GlFunction.setViewport(x, y, width, height);
    }

    override int getX() {
        return this.x;
    }
    override int getY() {
        return this.y;
    }
    override uint getWidth() {
        return this.width;
    }
    override uint getHeight() {
        return this.height;
    }

    void setLeft(int x) in {
        assert(x <= this.x + this.width);
    } body {
        this.width = this.x + this.width - x;
        this.x = x;
    }

    void setRight(int x) in {
        assert(x >= this.x);
    } body {
        this.width = x - this.x;
    }

    void setBottom(int y) in {
        assert(y <= this.y + this.height);
    } body {
        this.height = this.y + this.height - y;
        this.y = y;
    }

    void setTop(int y) in {
        assert(y >= this.y);
    } body {
        this.width = y - this.y;
    }

private:
}
