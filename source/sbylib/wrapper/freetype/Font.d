module sbylib.wrapper.freetype.Font;

import derelict.freetype.ft;
import sbylib.wrapper.gl;
import std.string;
import sbylib.wrapper.freetype.Constants;
import sbylib.wrapper.freetype.LetterInfo;

class Font {

    private {
        FT_Face face;
    }
    immutable int size;
    LetterInfo[dchar] characters;
    private FontType fontType;

    package(sbylib) this(FT_Face face, int size, FontType fontType) {
        this.face = face;
        this.size = size;
        assert(!FT_Set_Pixel_Sizes(this.face, 0, size), "Failed to set pixel size!");
    }

    void loadChar(dchar c, FontLoadType loadType) {
        if (c in this.characters) return;
        assert (!FT_Load_Char(this.face, c, loadType), "Failed to load character!");
        this.characters[c] = new LetterInfo(this.face.glyph, this.face.size.metrics, this.fontType);
    }

}
