module sbylib.loader.ImageLoader;

import std.stdio, std.string;
import derelict.freeimage.freeimage;

class ImageLoader {
    static Image load(string path) {
        auto type = FreeImage_GetFileType(path.toStringz,0);
        assert(type != -1, path ~ " was not found.");
        FIBITMAP* origin = FreeImage_Load(type,path.toStringz);
        assert(origin, path ~ " exists, but cannot load.");
        FIBITMAP* bitmap = FreeImage_ConvertTo32Bits(origin);
        FreeImage_Unload(origin);

        return new Image(bitmap);
    }
}

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
