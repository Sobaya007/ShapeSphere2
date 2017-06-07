module sbylib.loader.FontLoader;

import derelict.freetype.ft;
import sbylib.character.Font;
import std.string;

class FontLoader {
    private static FT_Library library;

    static void init() {
        assert(!FT_Init_FreeType(&library), "Failed to init freetype!");
    }

    static Font load(string path, FontType type, int size) {
        FT_Face face;
        assert(!FT_New_Face(library, path.toStringz, 0, &face), "Failed to load font!");
        return new Font(face, type, size);
    }
}
