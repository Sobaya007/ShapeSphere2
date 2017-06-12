module sbylib.wrapper.freeimage.FreeImage;

import derelict.freeimage.freeimage;
import sbylib.setting;

class FreeImage {

    static void init() {
        DerelictFI.load(FREEIMAGE_DLL_PATH);
    }
}
