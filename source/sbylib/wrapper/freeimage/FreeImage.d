module sbylib.wrapper.freeimage.FreeImage;

import derelict.freeimage.freeimage;

import sbylib.utils.Path;

class FreeImage {

    static void init() {
        version (Windows) {
            DerelictFI.load(FREEIMAGE_DLL_PATH);
        }
        version (OSX) {
            DerelictFI.load();
        }
    }
}
