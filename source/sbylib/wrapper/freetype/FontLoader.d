module sbylib.wrapper.freetype.FontLoader;

import derelict.freetype.ft;
import sbylib.setting;
import sbylib.wrapper.freetype.FreeType;
import sbylib.wrapper.freetype.Font;
import std.string;

class FontLoader {
    static Font load(string path, FontType type, int size) {
        FT_Face face;
        assert(!FT_New_Face(FreeType.library, path.toStringz, 0, &face), "Failed to load font!");
        return new Font(face, type, size);
    }
}
