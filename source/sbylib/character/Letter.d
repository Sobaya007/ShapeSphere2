module sbylib.character.Letter;

import sbylib.wrapper.freetype.LetterInfo;
import sbylib.wrapper.freetype.Font;
import sbylib.geometry.geometry2d.Rect;
import sbylib.material.TextMaterial;
import sbylib.mesh.Mesh;
import sbylib.math.Vector;
import sbylib.wrapper.freetype.Constants;

class Letter {

    alias LetterMesh = MeshTemp!(GeometryRect, TextMaterial);

    private Entity entity;
    private LetterInfo info;

    this(Letter letter) {
        this.info = letter.info;
        this.entity = new Entity;
        this.entity.setMesh(letter.entity.getMesh());
    }

    this(Font font, dchar c, float height) {
        font.loadChar(c, FontLoadType.Render);
        this.info = font.characters[c];
        auto geom = Rect.create(height * this.info.width / this.info.height, height);
        auto mesh = new LetterMesh(geom);
        mesh.mat.texture = this.info.texture;
        mesh.mat.color = vec4(0,0,0,1);
        this.entity = new Entity;
        this.entity.setMesh(mesh);
    }

    Entity getEntity() {
        return this.entity;
    }

    LetterInfo getInfo() {
        return this.info;
    }
}
