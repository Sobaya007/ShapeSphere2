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
    private ubyte[] buffer;
    private LetterInfo[] beforeInfos;

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
        if (infos.empty) return;
        auto totalWidth = infos.back.pen + infos.back.offsetX + infos.back.width;
        auto maxHeight = infos.map!(i => i.maxHeight).maxElement;
        //assert(minHeight == maxHeight);
        import sbylib.utils;
        auto w = h * totalWidth / maxHeight;
        GlFunction.setPixelUnpackAlign(1);
        if (width != w || height != h) {
            buffer = new ubyte[totalWidth*maxHeight];
            this.entity.texture.allocate(0, ImageInternalFormat.R, cast(uint)totalWidth, cast(uint)maxHeight, ImageFormat.R, buffer.ptr);
            this.beforeInfos.length = 0;
        }
        foreach (before, info; zip(StoppingPolicy.longest, beforeInfos, infos)) {
            // modify
            if (before.c == info.c) continue;
            if (before != LetterInfo.init) {
                this.entity.texture.update(
                    0,
                    cast(uint)(before.pen+before.offsetX),
                    cast(uint)(before.offsetY),
                    cast(uint)before.width,
                    cast(uint)before.height,
                    ImageFormat.R,
                    buffer.ptr
                );
            }
            this.entity.texture.update(
                0,
                cast(uint)(info.pen+info.offsetX),
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
        this.beforeInfos = infos;
    }

    LetterEntity getEntity() {
        return this.entity;
    }

    alias getEntity this;
}
