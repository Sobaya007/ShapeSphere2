module sbylib.wrapper.freeimage.FreeImage;

import derelict.freeimage.freeimage;
import derelict.util.exception;

private ShouldThrow missingSymFunc(string symName) {
    return ShouldThrow.No;
}

class FreeImage {

    static void init() {
        DerelictFI.missingSymbolCallback = &missingSymFunc;
        DerelictFI.load();
    }
}
