module sbylib.character.StringTexture;


class StringTexture { 

    import sbylib.wrapper.gl.Texture;
    import sbylib.wrapper.freetype.Font;
    import sbylib.character.Label;
    import std.traits : isSomeString;

    private Texture mTexture;
    private float width, height;
    private ubyte[] buffer;
    private Label.Char[] beforeRow;

    this() {
        import sbylib.wrapper.gl.Constants;
        this.mTexture = new Texture(TextureTarget.Tex2D);
        this.texture.setWrapS(TextureWrap.ClampToEdge);
        this.texture.setWrapT(TextureWrap.ClampToEdge);
    }

    void setBuffer(Font font, string str) {
        import std.algorithm : map;
        import std.array : array;
        import sbylib.math.Vector;
        setBuffer(str.map!(c => Label.Char(font.getLetterInfo(c), vec4(1))).array);
    }

    void setBuffer(Label.Char[] row) {
        import std.algorithm : map, sum, maxElement;
        import std.range;
        import std.array : empty;
        import sbylib.wrapper.gl.Constants;
        import sbylib.wrapper.gl.Functions;

        if (row.empty) return;
        auto infos = row.map!(c => c.info);
        auto totalWidth = infos.map!(i=>i.advance).sum;
        auto minHeight = infos.map!(i => i.maxHeight).maxElement;
        auto maxHeight = infos.map!(i => i.maxHeight).maxElement;
        //assert(minHeight == maxHeight);
        import sbylib.utils;
        GlFunction().setPixelUnpackAlign(1);
        if (width != totalWidth || height != maxHeight) {
            buffer = new ubyte[cast(size_t)(totalWidth*maxHeight)];
            this.texture.allocate(0, ImageInternalFormat.R, cast(uint)totalWidth, cast(uint)maxHeight, ImageFormat.R, buffer.ptr);
            this.width = totalWidth;
            this.height = maxHeight;
            this.beforeRow.length = 0;
        }
        int pen = 0;
        auto beforeInfos = beforeRow.map!(c => c.info);
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
        GlFunction().setPixelUnpackAlign(4);

        this.beforeRow = row;
    }

    float aspectRatio() {
        return this.width / this.height;
    }

    Texture texture() {
        return mTexture;
    }

    alias texture this;
}
