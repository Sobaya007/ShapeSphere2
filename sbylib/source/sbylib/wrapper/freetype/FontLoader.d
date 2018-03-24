module sbylib.wrapper.freetype.FontLoader;

import derelict.freetype.ft;
import sbylib.wrapper.freetype.Constants;
import sbylib.wrapper.freetype.FreeType;
import sbylib.wrapper.freetype.Font;
import std.string;

class FontLoader {
    static Font load(string path, int size) {
        FT_Face face;
        auto result = FT_New_Face(FreeType.library, path.toStringz, 0, &face);
        assert(!result, "Failed to load font!");
        return new Font(face, size, FontType.Mono);
    }
}
