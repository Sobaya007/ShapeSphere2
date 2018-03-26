module sbylib.character.Sentence;

import sbylib.wrapper.freetype.Font;
import sbylib.geometry.geometry2d.Rect;
import sbylib.material.TextMaterial;
import sbylib.math.Vector;
import sbylib.entity.TypedEntity;
import sbylib.character.StringTexture;

class Sentence {

    alias LetterEntity = TypedEntity!(GeometryRect, TextMaterial);

    private LetterEntity entity;

    private StringTexture stringTexture;

    this() {
        this.entity = makeEntity(Rect.create(1, 1), new TextMaterial);
        this.entity.color = vec4(0,0,0,1);
        this.entity.config.renderGroupName = "transparent";
        this.entity.config.depthTest = false;

        this.stringTexture = new StringTexture;
        this.entity.texture = this.stringTexture;
        this.entity.name = "Sentence";
    }

    void setBuffer(Font.LetterInfo[] infos, float h) {
        this.stringTexture.setBuffer(infos);
        
        auto w = h * this.stringTexture.aspectRatio;
        this.entity.scale.xy = vec2(w, h);
    }

    LetterEntity getEntity() {
        return this.entity;
    }

    float width() {
        return this.entity.scale.x;
    }

    float height() {
        return this.entity.scale.y;
    }

    alias getEntity this;
}
