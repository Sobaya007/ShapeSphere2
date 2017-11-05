module sbylib.wrapper.freetype.FreeType;

import derelict.freetype.ft;
import derelict.util.exception;
import sbylib.setting;

import std.algorithm;

private enum deadFunctions = [
    "FT_Stream_OpenBzip2",
    "FT_Get_CID_Registry_Ordering_Supplement",
    "FT_Get_CID_Is_Internally_CID_Keyed",
    "FT_Get_CID_From_Glyph_Index",
    ];

private ShouldThrow missingSymFunc(string symName) {
    if (deadFunctions.any!(d => d == symName)) return ShouldThrow.No;
    return ShouldThrow.Yes;
}

class FreeType {

    public static FT_Library library;

    private this(){}

    public static void init() {
        import std.stdio;
        version (Windows) {
            DerelictFT.missingSymbolCallback = &missingSymFunc;
            DerelictFT.load(FREETYPE_DLL_PATH);
        }
        version (OSX) {
            DerelictFT.load();
        }
        assert(!FT_Init_FreeType(&library), "Failed to init freetype!");
    }
}
