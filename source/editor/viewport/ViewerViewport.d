module editor.viewport.ViewerViewport;

import sbylib;

class ViewerViewport : IViewport {

    private int x, y;
    private uint width, height;
    private int innerX, innerY;
    private int innerWidth, innerHeight;
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
        update();
    }

    override void set() {
        GlFunction.setViewport(innerX, innerY, innerWidth, innerHeight);
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

    void setLeft(int x) in {
        assert(x <= this.x + this.width);
    } body {
        this.width = this.x + this.width - x;
        this.x = x;
        update();
    }

    void setRight(int x) in {
        assert(x >= this.x);
    } body {
        this.width = x - this.x;
        update();
    }

    void setBottom(int y) in {
        assert(y <= this.y + this.height);
    } body {
        this.height = this.y + this.height - y;
        this.y = y;
        update();
    }

    void setTop(int y) in {
        assert(y >= this.y);
    } body {
        this.width = y - this.y;
        update();
    }

    void setRect(int x, int y, uint width, uint height) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        update();
    }

private:
    void update() {
        this.innerX = this.x;
        this.innerY = this.y;
        this.innerWidth = this.width;
        this.innerHeight = this.height;
        if (this.innerWidth > this.innerHeight * this.aspect) {
            this.innerWidth = cast(uint)(this.innerHeight * this.aspect);
        } else {
            this.innerHeight = cast(uint)(this.innerWidth / this.aspect);
        }
        this.innerX = (this.width - this.innerWidth) / 2 + this.x;
        this.innerY = (this.height - this.innerHeight) / 2 + this.y;
    }
}
