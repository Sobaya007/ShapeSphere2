module sbylib.character.Letter;

import sbylib.wrapper.freetype.LetterInfo;
import sbylib.wrapper.freetype.Font;
import sbylib.geometry.geometry2d.Rect;
import sbylib.material.TextMaterial;
import sbylib.math.Vector;
import sbylib.wrapper.freetype.Constants;
import sbylib.entity.TypedEntity;

class Letter {

    alias LetterEntity = TypedEntity!(GeometryRect, TextMaterial);

    private LetterEntity entity;
    private LetterInfo info;

    float width, height;

    this() {
        this.entity = makeEntity(Rect.create(1, 1), new TextMaterial);
        this.entity.color = vec4(0,0,0,1);
        this.entity.config.renderGroupName = "transparent";
        this.entity.config.depthTest = false;
    }

    void setChar(Font font, dchar c, float h) {
        font.loadChar(c, FontLoadType.Render);
        this.info = font.characters[c];
        auto w = h * this.info.width / this.info.height;
        this.entity.texture = this.info.texture;
        this.entity.scale.xy = vec2(w, h);
        this.entity.name = "Letter '" ~ cast(char)c ~ "'";

        this.width = w;
        this.height = h;
    }

    LetterEntity getEntity() {
        return this.entity;
    }

    LetterInfo getInfo() {
        return this.info;
    }

    alias getEntity this;
}
