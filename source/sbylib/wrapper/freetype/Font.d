module sbylib.wrapper.freetype.Font;

import derelict.freetype.ft;
import sbylib.wrapper.gl;
import sbylib.setting;
import std.string;
import sbylib.wrapper.freetype.Constants;
import sbylib.wrapper.freetype.Character;

class Font {

    private {
        FT_Face face;
    }
    immutable int size;
    Character[char] characters;
    private FontType fontType;

    this(FT_Face face, int size, FontType fontType) {
        this.face = face;
        this.size = size;
        assert(!FT_Set_Pixel_Sizes(this.face, 0, size), "Failed to set pixel size!");
    }

    void loadChar(char c, FontLoadType loadType) {
        assert (!FT_Load_Char(this.face, c, loadType), "Failed to load character!");
        this.characters[c] = new Character(this.face.glyph, this.face.size.metrics, this.fontType);
    }

}
