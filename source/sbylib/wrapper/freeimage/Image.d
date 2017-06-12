module sbylib.wrapper.freeimage.Image;

import derelict.freeimage.freeimage;

class Image {

    FIBITMAP* bitmap;

    this(FIBITMAP* bitmap) {
        this.bitmap = bitmap;
    }

    ~this() {
        FreeImage_Unload(bitmap);
    }

    int getWidth() {
        return FreeImage_GetWidth(bitmap);
    }

    int getHeight() {
        return FreeImage_GetHeight(bitmap);
    }

    void* getBits() {
        return FreeImage_GetBits(bitmap);
    }
}
