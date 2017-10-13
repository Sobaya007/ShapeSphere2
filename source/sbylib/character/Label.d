module sbylib.character.Label;

import sbylib.geometry.geometry2d.Rect;
import sbylib.wrapper.freetype.Constants;
import sbylib.wrapper.freetype.Font;
import sbylib.mesh.Mesh;
import sbylib.material.TextMaterial;
import sbylib.mesh.Object3D;
import sbylib.math.Vector;
import sbylib.utils.Watcher;
import sbylib.character.Letter;
import std.typecons;
import std.math;

class Label {

    alias entity this;

    enum OriginX {Center, Left, Right}
    enum OriginY {Center, Top, Bottom}

    Entity entity;
    private Letter[] letters;
    private vec4 color;
    private Font font;
    private OriginX originX;
    private OriginY originY;
    private float wrapWidth;
    private float size; //1 letter height
    private Letter[dchar] cache;
    private float width, height;

    this(Font font, float size) {
        this.font = font;
        this.originX = OriginX.Center;
        this.originY = OriginY.Center;
        this.wrapWidth = 1145141919.810;
        this.size = size;
        this.color = vec4(0,0,0,1);
        this.entity = new Entity;
    }

    void setColor(vec4 color) {
        this.color = color;
        foreach (l; this.letters) {
            auto mat = cast(TextMaterial)l.getEntity().getMesh().mat;
            mat.color = color;
        }
    }

    vec4 getColor() {
        return this.color;
    }

    void setSize(float size) {
        this.size = size;
        this.lineUp();
    }

    void setWrapWidth(float wrapWidth) {
        this.wrapWidth = wrapWidth;
        this.lineUp();
    }

    void setOrigin(OriginX x, OriginY y) {
        this.originX = x;
        this.originY = y;
        this.lineUp();
    }

    float getWidth() {
        return this.width;
    }

    float getHeight() {
        return this.height;
    }

    void renderText(dstring text) {
        this.entity.clearChildren();
        this.letters = [];
        foreach (c; text) {
            Letter l;
            if (c in cache) {
                l = new Letter(cache[c]);
            } else {
                l = new Letter(this.font, c, this.size);
                cache[c] = l;
            }
            this.entity.addChild(l.getEntity());
            this.letters ~= l;
        }
        this.setColor(this.color);
        this.lineUp();
    }

    vec3 getPos(OriginX ox, OriginY oy) {
        return this.obj.pos + vec3(offsetX(this.originX,this.width) - offsetX(OriginX.Center,this.width), offsetY(this.originY) - offsetY(OriginY.Center), 0);
    }

    struct RowInfo {
        Letter[] letters;
        float width;
    }

    private void lineUp() {
        auto rows = getRows(null, this.letters, null, 0);
        this.width = 0;
        foreach (row; rows) {
            this.width = fmax(this.width, row.width);
        }
        this.height = rows.length * this.size;
        auto y = this.offsetY(this.originY);
        alias h = this.size;
        foreach (row; rows) {
            if (row.letters.length == 0) continue;
            float x = this.offsetX(this.originX, row.width);
            int count = 0;
            foreach (l; row.letters) {
                auto w = h * l.getInfo().width / l.getInfo().height;
                x += w/2;
                l.getEntity().obj.pos = vec3(x, y, 0);
                x += w/2;
            }
            y -= h;
        }
    }

    private RowInfo[] getRows(Letter[] buffer, Letter[] rest, RowInfo[] rows, float w) {
        if (rest.length == 0) return rows ~ RowInfo(buffer, w);
        auto l = rest[0];
        auto dw = this.size * l.getInfo().width / l.getInfo().height;
        rest = rest[1..$];
        if (w + dw < this.wrapWidth) return getRows(buffer ~ l, rest, rows, w + dw);
        rows ~= RowInfo(buffer, w);
        return getRows([l], rest, rows, dw);
    }

    private float offsetX(OriginX ox, float fullWidth) {
        final switch (ox) {
        case OriginX.Left:
            return 0;
        case OriginX.Center:
            return -fullWidth / 2;
        case OriginX.Right:
            return -fullWidth;
        }
    }

    private float offsetY(OriginY oy) {
        final switch (oy) {
        case OriginY.Top:
            return -this.size / 2;
        case OriginY.Center:
            return this.height / 2 - this.size / 2;
        case OriginY.Bottom:
            return this.height - this.size / 2;
        }
    }

    alias entity this;
}
