module sbylib.wrapper.freeimage.FreeImage;

import derelict.freeimage.freeimage;
import derelict.util.exception;

import std.algorithm : any;

import sbylib.utils.Path;

private ShouldThrow missingSymFunc(string symName) {
    return ShouldThrow.No;
}

class FreeImage {

    static void init() {
        version (Windows) {
            DerelictFI.load(DllPath("FreeImage.dll"));
        } else {
            DerelictFI.missingSymbolCallback = &missingSymFunc;
            DerelictFI.load();
        }
    }
}
