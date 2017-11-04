module sbylib.wrapper.freeimage.FreeImage;

import derelict.freeimage.freeimage;

import sbylib.utils.Path;

class FreeImage {

    static void init() {
        DerelictFI.load(DllPath("FreeImage.dll"));
    }
}
