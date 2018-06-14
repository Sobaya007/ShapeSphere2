module sbylib.character.Sentence;

import sbylib.wrapper.freetype.Font;
import sbylib.geometry.geometry2d.Rect;
import sbylib.material.TextMaterial;
import sbylib.math.Vector;
import sbylib.entity.TypedEntity;
import sbylib.character.StringTexture;

class Sentence {

    alias LetterEntity = TypedEntity!(GeometryRect, TextMaterial);

    private LetterEntity mEntity;

    private StringTexture stringTexture;

    this() {
        this.mEntity = makeEntity(Rect.create(1, 1), new TextMaterial);
        this.mEntity.color = vec4(0,0,0,1);
        this.mEntity.config.renderGroupName = "transparent";
        this.mEntity.config.depthTest = false;

        this.stringTexture = new StringTexture;
        this.mEntity.texture = this.stringTexture;
        this.mEntity.name = "Sentence";
    }

    void setBuffer(Font.LetterInfo[] infos, float h) {
        this.stringTexture.setBuffer(infos);
        
        auto w = h * this.stringTexture.aspectRatio;
        this.mEntity.scale.xy = vec2(w, h);
    }

    LetterEntity entity() {
        return this.mEntity;
    }

    float width() {
        return this.mEntity.scale.x;
    }

    float height() {
        return this.mEntity.scale.y;
    }

    alias entity this;
}
