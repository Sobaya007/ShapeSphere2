module sbylib.character.Sentence;

class Sentence {

    import sbylib.geometry.geometry2d.Rect;
    import sbylib.material.TextMaterial;
    import sbylib.math.Vector;
    import sbylib.entity.TypedEntity;
    import sbylib.character.Label;
    import sbylib.character.StringTexture;
    import sbylib.wrapper.freetype.Font;

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

    void setBuffer(Label.Char[] row, float h) {
        this.stringTexture.setBuffer(row);
        
        auto w = h * this.stringTexture.aspectRatio;
        this.mEntity.scale.xy = vec2(w, h);

        import std.algorithm : map, sum;
        import std.range : enumerate;
        auto widthList = row.map!(c => c.info.advance);
        float totalWidth = widthList.sum;
        foreach (i, width; widthList.enumerate) {
            this.mEntity.charWidths[i] = width / totalWidth;
        }
        foreach (i, color; row.map!(c => c.color).enumerate) {
            this.mEntity.textColors[i] = color;
        }
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

    void setColor(size_t i, vec4 color) {
        this.mEntity.textColors[i] = color;
    }

    alias entity this;
}
