module sbylib.wrapper.freetype.FreeType;

import derelict.freetype.ft;
import sbylib.setting;

class FreeType {

    public static FT_Library library;

    private this(){}

    public static void init() {
        DerelictFT.load(FREETYPE_DLL_PATH);
        assert(!FT_Init_FreeType(&library), "Failed to init freetype!");
    }
}
