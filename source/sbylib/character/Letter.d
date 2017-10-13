module sbylib.character.Letter;

import sbylib.wrapper.freetype.LetterInfo;
import sbylib.wrapper.freetype.Font;
import sbylib.geometry.geometry2d.Rect;
import sbylib.material.TextMaterial;
import sbylib.mesh.Mesh;
import sbylib.math.Vector;
import sbylib.wrapper.freetype.Constants;

class Letter {

    alias LetterEntity = EntityTemp!(GeometryRect, TextMaterial);

    private LetterEntity entity;
    private LetterInfo info;
    const float width, height;

    this(Letter letter) {
        this.info = letter.info;
        auto before = letter.getEntity().getMesh();
        this.entity = new LetterEntity(before.geom, before.mat);
        this.width = letter.width;
        this.height = letter.height;
    }

    this(Font font, dchar c, float h) {
        font.loadChar(c, FontLoadType.Render);
        this.info = font.characters[c];
        this.width = h * this.info.width / this.info.height;
        this.height = h;
        auto geom = Rect.create(this.width, this.height);
        this.entity = new LetterEntity(geom);
        this.entity.getMesh().mat.texture = this.info.texture;
        this.entity.getMesh().mat.color = vec4(0,0,0,1);
    }

    LetterEntity getEntity() {
        return this.entity;
    }

    LetterInfo getInfo() {
        return this.info;
    }
}
