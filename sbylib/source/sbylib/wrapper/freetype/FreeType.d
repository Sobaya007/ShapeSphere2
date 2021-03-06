module sbylib.wrapper.freetype.FreeType;

import derelict.freetype.ft;
import derelict.util.exception;

import std.algorithm;

import sbylib.utils.Path;

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
            DerelictFT.load(DllPath("freetype.dll"));
        } else {
            DerelictFT.load();
        }
        auto result = FT_Init_FreeType(&library);
        assert(!result, "Failed to init freetype!");
    }
}
