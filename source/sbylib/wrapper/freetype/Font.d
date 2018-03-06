module sbylib.wrapper.freetype.Font;

import derelict.freetype.ft;
import sbylib.wrapper.gl;
import std.string;
import sbylib.wrapper.freetype.Constants;

class Font {

    private {
        FT_Face face;
    }
    immutable int size;
    private FontType fontType;
    private LetterInfo[dchar] cache;

    package(sbylib) this(FT_Face face, int size, FontType fontType) {
        this.face = face;
        this.size = size;
        auto result = FT_Set_Pixel_Sizes(this.face, 0, size);
        assert(!result, "Failed to set pixel size!");
    }

    private void loadChar(dchar c, FontLoadType loadType) {
        auto result = FT_Load_Char(this.face, c, loadType);
        assert (!result, "Failed to load character!");
    }

    struct LetterInfo {
        dchar c;
        long offsetX, offsetY;
        long width, height;
        long advance;
        long maxHeight;
        ubyte[] bitmap;
    }

    auto getLetterInfo(dchar c) {
        if (auto r = c in cache) return *r;
        loadChar(c, FontLoadType.Render);
        auto glyph = face.glyph;
        auto sz = face.size.metrics;
        FT_Glyph_Metrics met = glyph.metrics;

        auto bearingX = met.horiBearingX/64;
        auto bearingY = met.horiBearingY/64;
        auto width = glyph.bitmap.width;
        auto height = glyph.bitmap.rows;

        auto ascender = sz.ascender / 64;
        auto advance = glyph.advance.x/64;
        auto maxHeight = (sz.ascender - sz.descender) / 64;

        auto offsetX = bearingX;
        auto offsetY = ascender - bearingY;

        auto bm = glyph.bitmap;

        assert(bm.pitch == width);

        auto bm2 = bm.buffer[0..width*height].dup;

        return cache[c] = LetterInfo(c, offsetX, offsetY, width, height, advance, maxHeight, bm2);
    }
}
