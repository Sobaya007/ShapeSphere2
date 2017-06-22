module sbylib.character.Label;

import sbylib.geometry.geometry2d.Rect;
import sbylib.wrapper.freetype.Character;
import sbylib.wrapper.freetype.Constants;
import sbylib.wrapper.freetype.Font;
import sbylib.mesh.Mesh;
import sbylib.material.TextureMaterial;
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

    this(Font font, float scale = 1) {
        this.font = font;
        this.text = new Watch!string;
        this.obj = new Object3D;
        this.meshes = new Watcher!(Mesh[])((ref Mesh[] m) {
            m = generateMesh(scale * 0.01);
        }, null);
    }

    float getWidth() {
        return this.width;
    }

    float getHeight() {
        return this.height;
    }

    private auto generateMesh(float scale) {
        auto x = 0.0f;
        Mesh[] meshes;
        this.width = 0;
        foreach (c; text) {
            font.loadChar(c, FontLoadType.Render);
            auto chara = font.characters[c];
            auto geom = Rect.create(chara.width * scale, chara.height * scale);
            auto mat = new TextureMaterial;
            mat.texture = chara.texture;
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
