module sbylib.character.Sentence;

import sbylib.character.Label;
import sbylib.wrapper.freetype.Font;
import sbylib.geometry.geometry2d.Rect;
import sbylib.material.TextMaterial;
import sbylib.math.Vector;
import sbylib.wrapper.freetype.Constants;
import sbylib.entity.TypedEntity;
import sbylib.wrapper.gl;

class Sentence {

    alias LetterEntity = TypedEntity!(GeometryRect, TextMaterial);

    private LetterEntity entity;

    float width, height;

    this() {
        this.entity = makeEntity(Rect.create(1, 1), new TextMaterial);
        this.entity.color = vec4(0,0,0,1);
        this.entity.config.renderGroupName = "transparent";
        this.entity.config.depthTest = false;
        this.entity.texture = new Texture(TextureTarget.Tex2D);
        this.entity.texture.setWrapS(TextureWrap.ClampToEdge);
        this.entity.texture.setWrapT(TextureWrap.ClampToEdge);
    }

    void setBuffer(LetterInfo[] infos, float h) {
        import std.algorithm, std.range;
        auto maxWidth = infos.map!(i => i.maxWidth).sum;
        auto minHeight = infos.map!(i => i.maxHeight).minElement;
        auto maxHeight = infos.map!(i => i.maxHeight).maxElement;
        assert(minHeight == maxHeight);
        import sbylib.utils;
        auto w = h * maxWidth / maxHeight;
        GlFunction.setPixelUnpackAlign(1);
        if (width != maxWidth || height != maxHeight) {
            this.entity.texture.allocate(0, ImageInternalFormat.R, cast(uint)maxWidth+5, cast(uint)maxHeight, ImageFormat.R, (ubyte*).init);
        }
        foreach (info; infos) {
            this.entity.texture.update(
                0,
                cast(uint)(info.ox+info.offsetX),
                cast(uint)(info.offsetY),
                cast(uint)info.width,
                cast(uint)info.height,
                ImageFormat.R,
                info.bitmap.ptr
            );
        }
        GlFunction.setPixelUnpackAlign(4);
        this.entity.scale.xy = vec2(w, h);

        this.width = w;
        this.height = h;
    }

    LetterEntity getEntity() {
        return this.entity;
    }

    alias getEntity this;
}
