module sbylib.wrapper.freeimage.Image;

import derelict.freeimage.freeimage;
import sbylib.wrapper.freeimage.Constants;
import std.conv;

class Image {

    private FIBITMAP* bitmap;

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

    ubyte* getBits() {
        return FreeImage_GetBits(bitmap);
    }

    ImageType getImageType() {
        return FreeImage_GetImageType(bitmap).to!ImageType;
    }
}
