module sbylib.wrapper.freeimage.ImageLoader;

public import sbylib.wrapper.freeimage.Image;

class ImageLoader {
    static Image load(string path) {
        import std.stdio, std.string;
        import derelict.freeimage.freeimage;
        auto type = FreeImage_GetFileType(path.toStringz,0);
        assert(type != -1, path ~ " was not found.");
        FIBITMAP* origin = FreeImage_Load(type,path.toStringz);
        assert(origin, path ~ " exists, but cannot load.");
        FIBITMAP* bitmap = FreeImage_ConvertTo32Bits(origin);
        FreeImage_Unload(origin);

        return new Image(bitmap);
    }
}
