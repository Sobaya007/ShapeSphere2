module sbylib.wrapper.freeimage.FreeImage;

import derelict.freeimage.freeimage;

import sbylib.utils.Path;

class FreeImage {

    static void init() {
        version (Windows) {
            DerelictFI.load(DllPath("FreeImage.dll"));
        } else {
            DerelictFI.load();
        }
    }
}
