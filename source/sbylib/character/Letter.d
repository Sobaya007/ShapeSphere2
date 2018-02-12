module sbylib.character.Letter;

import sbylib.wrapper.freetype.LetterInfo;
import sbylib.wrapper.freetype.Font;
import sbylib.geometry.geometry2d.Rect;
import sbylib.material.TextMaterial;
import sbylib.entity.Mesh;
import sbylib.math.Vector;
import sbylib.wrapper.freetype.Constants;

class Letter {

    alias LetterEntity = TypedEntity!(GeometryRect, TextMaterial);

    private LetterEntity entity;
    private LetterInfo info;
    const float width, height;

    this(Letter letter) {
        this.info = letter.info;
        this.entity = makeEntity(letter.geom, letter.mat);
        this.entity.name = letter.entity.name;
        this.width = letter.width;
        this.height = letter.height;
    }

    this(Font font, dchar c, float h) {
        font.loadChar(c, FontLoadType.Render);
        this.info = font.characters[c];
        this.width = h * this.info.width / this.info.height;
        this.height = h;
        auto geom = Rect.create(this.width, this.height);
        this.entity = makeEntity(geom, new TextMaterial);
        this.entity.texture = this.info.texture;
        this.entity.color = vec4(0,0,0,1);
        this.entity.config.renderGroupName = "transparent";
        this.entity.config.depthTest = false;
        this.entity.name = "Letter '" ~ cast(char)c ~ "'";
    }

    LetterEntity getEntity() {
        return this.entity;
    }

    LetterInfo getInfo() {
        return this.info;
    }

    alias getEntity this;
}
