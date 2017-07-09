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

class Label {

    enum OriginX {Center, Left, Right}
    enum OriginY {Center, Top, Bottom}

    MeshGroup mesh;
    private Letter[] letters;
    private vec4 color;
    private Font font;
    private OriginX originX;
    private OriginY originY;
    private float wrapWidth;
    private float size; //1 letter height
    private Letter[dchar] cache;

    this(Font font) {
        this.font = font;
        this.originX = OriginX.Center;
        this.originY = OriginY.Center;
        this.wrapWidth = 1145141919.810;
        this.color = vec4(0,0,0,1);
        this.mesh = new MeshGroup;
    }

    void setColor(vec4 color) {
        this.color = color;
        foreach (l; this.letters) {
            l.getMesh().mat.color = color;
        }
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

    void renderText(dstring text) {
        this.mesh.clear();
        this.letters = [];
        foreach (c; text) {
            Letter l;
            if (c in cache) {
                l = new Letter(cache[c]);
            } else {
                l = new Letter(this.font, c, this.size);
                cache[c] = l;
            }
            this.mesh.add(l.getMesh());
            l.getMesh().mat.color = this.color;
            this.letters ~= l;
        }
        this.lineUp();
    }

    struct RowInfo {
        Letter[] letters;
        float width;
    }

    private void lineUp() {
        auto rows = getRows(null, this.letters, null, 0);
        import std.stdio;
        auto allHeight = rows.length * this.size;
        auto y = this.offsetY(allHeight);
        alias h = this.size;
        foreach (row; rows) {
            if (row.letters.length == 0) continue;
            float x = this.offsetX(row.width, h * row.letters[0].getInfo().width / row.letters[0].getInfo().height);
            int count = 0;
            foreach (l; row.letters) {
                auto w = h * l.getInfo().width / l.getInfo().height;
                x += w/2;
                l.getMesh().obj.pos = vec3(x, y, 0);
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

    private float offsetX(float fullWidth, float width) {
        final switch (this.originX) {
        case OriginX.Left:
            return 0;
        case OriginX.Center:
            return -fullWidth / 2;
        case OriginX.Right:
            return -fullWidth;
        }
    }

    private float offsetY(float height) {
        final switch (this.originY) {
        case OriginY.Top:
            return -this.size / 2;
        case OriginY.Center:
            return +height / 2 - this.size / 2;
        case OriginY.Bottom:
            return height - this.size / 2;
        }
    }
}
