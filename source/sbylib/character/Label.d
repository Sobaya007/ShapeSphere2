module sbylib.character.Label;

import sbylib.geometry.geometry2d.Rect;
import sbylib.wrapper.freetype.Character;
import sbylib.wrapper.freetype.Constants;
import sbylib.wrapper.freetype.Font;
import sbylib.mesh.Mesh;
import sbylib.material.TextMaterial;
import sbylib.mesh.Object3D;
import sbylib.math.Vector;
import sbylib.utils.Watcher;
import std.typecons;

class Label {

    private Font font;
    Watch!string text;
    Object3D obj;
    Watcher!(Mesh[]) meshes;
    private float width;
    private float height;

    this(Font font, float h, vec3 color = vec3(0)) {
        this.font = font;
        this.text = new Watch!string;
        this.obj = new Object3D;
        this.meshes = new Watcher!(Mesh[])((ref Mesh[] m) {
            m = generateMesh(h, color);
        }, null);
    }

    float getWidth() {
        return this.width;
    }

    float getHeight() {
        return this.height;
    }

    private auto generateMesh(float h, vec3 color) {
        auto x = 0.0f;
        Mesh[] meshes;
        this.width = 0;
        foreach (c; text) {
            font.loadChar(c, FontLoadType.Render);
            auto chara = font.characters[c];
            float scale = h / chara.height;
            auto geom = Rect.create(chara.width * scale, chara.height * scale);
            auto mat = new TextMaterial;
            mat.texture = chara.texture;
            mat.color = color;
            auto mesh = new Mesh(geom, mat);
            mesh.obj.setParent(obj);
            mesh.obj.pos = vec3(x,0,0);
            x += chara.width * scale;
            meshes ~= mesh;
            this.width += chara.width * scale;
            this.height = chara.height * scale;
        }
        foreach (m; meshes) {
            m.obj.pos.x -= this.width / 2;
        }
        return meshes;
    }
}
