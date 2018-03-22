module sbylib.character.StringTexture;

import sbylib.wrapper.gl.Texture;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.freetype.Font;
import sbylib.character.Label;
import std.traits;

class StringTexture {

    private Texture _texture;
    private float width, height;
    private ubyte[] buffer;
    private Font.LetterInfo[] beforeInfos;

    this() {
        this._texture = new Texture(TextureTarget.Tex2D);
        this.texture.setWrapS(TextureWrap.ClampToEdge);
        this.texture.setWrapT(TextureWrap.ClampToEdge);
    }
    
    this(String)(Font font, String str) if (isSomeString!(String)) {
        this();
        setBuffer(font, str);
    }

    void setBuffer(String)(Font font, String str) if (isSomeString!(String)) {
        import std.algorithm, std.array;
        setBuffer(str.map!(c => font.getLetterInfo(c)).array);
    }

    void setBuffer(Font.LetterInfo[] infos) {
        import std.algorithm, std.range;
        if (infos.empty) return;
        auto totalWidth = infos.map!(i=>i.advance).sum + infos.back.offsetX + infos.back.width;
        auto minHeight = infos.map!(i => i.maxHeight).maxElement;
        auto maxHeight = infos.map!(i => i.maxHeight).maxElement;
        //assert(minHeight == maxHeight);
        import sbylib.utils;
        GlFunction.setPixelUnpackAlign(1);
        if (width != totalWidth || height != maxHeight) {
            buffer = new ubyte[cast(size_t)(totalWidth*maxHeight)];
            this.texture.allocate(0, ImageInternalFormat.R, cast(uint)totalWidth, cast(uint)maxHeight, ImageFormat.R, buffer.ptr);
            this.width = totalWidth;
            this.height = maxHeight;
            this.beforeInfos.length = 0;
        }
        int pen = 0;
        foreach (before, info; zip(StoppingPolicy.longest, beforeInfos, infos)) {
            scope(exit) pen += info.advance;
            // modify
            if (before.c == info.c) continue;
            if (before != Font.LetterInfo.init) {
                this.texture.update(
                    0,
                    cast(uint)(pen+before.offsetX),
                    cast(uint)(before.offsetY),
                    cast(uint)before.width,
                    cast(uint)before.height,
                    ImageFormat.R,
                    buffer.ptr
                );
            }
            this.texture.update(
                0,
                cast(uint)(pen+info.offsetX),
                cast(uint)(info.offsetY),
                cast(uint)info.width,
                cast(uint)info.height,
                ImageFormat.R,
                info.bitmap.ptr
            );
        }
        GlFunction.setPixelUnpackAlign(4);

        this.beforeInfos = infos;
    }

    float aspectRatio() {
        return this.width / this.height;
    }

    Texture texture() {
        return _texture;
    }

    alias texture this;
}
