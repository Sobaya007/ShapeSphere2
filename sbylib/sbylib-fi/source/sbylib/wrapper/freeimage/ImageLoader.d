module sbylib.wrapper.freeimage.ImageLoader;

public {
    import sbylib.wrapper.freeimage.Image;
    import sbylib.wrapper.freeimage.Constants;
}

import derelict.freeimage.freeimage;

class ImageLoader {
    static Image load(string path) {
        auto format = getFormat(path);
        assert(format != ImageFormat.Unknown, path ~ " was not found.");
        auto bitmap = load(format, path);
        return new Image(bitmap);
    }

    static Image loadAsGif(string path, GifLoadOption option) {
        return new Image(load(ImageFormat.Gif, path, option));
    }

    static Image loadAsIco(string path, IcoLoadOption option = IcoLoadOption.Default) {
        return new Image(load(ImageFormat.Ico, path, option));
    }

    static Image loadAsJpeg(string path, JpegLoadOption option, int scale, bool cmyk, bool useExifRotate) {
        option |= (scale << 16);
        if (cmyk) option |= JPEG_CMYK;
        if (useExifRotate) option |= JPEG_EXIFROTATE;
        return new Image(load(ImageFormat.Jpeg, path,option));
    }

    static Image loadAsPcd(string path, PcdLoadOption option) {
        return new Image(load(ImageFormat.Pcd, path, option));
    }

    static Image loadAsPng(string path, bool ignoreGamma) {
        int option = 0;
        if (ignoreGamma) option |= PNG_IGNOREGAMMA;
        return new Image(load(ImageFormat.Png, path, option));
    }

    static Image loadAsRaw(string path, RawLoadOption option) {
        return new Image(load(ImageFormat.Raw, path, option));
    }

    static Image loadAsTarga(string path, bool loadRGB888) {
        int option = 0;
        if (loadRGB888) option |= TARGA_LOAD_RGB888;
        return new Image(load(ImageFormat.Targa, path, option));
    }

    static Image loadAsTiff(string path, bool cmyk) {
        int option = 0;
        if (cmyk) option |= TIFF_CMYK;
        return new Image(load(ImageFormat.Tiff, path, option));
    }

    static ImageFormat getFormat(string path)
    in {
        import std.file : exists;
        import std.format;
        assert(exists(path), format!"'%s' does not exist."(path));
    }
    do {
        import std.string : toStringz;

        // 第2引数は現在使われていないらしい。
        return cast(ImageFormat)FreeImage_GetFileType(path.toStringz,0);
    }

    private static FIBITMAP* load(ImageFormat format, string path, int option = 0)
        out(result; result, path ~ " exists, but cannot load.")
    {
        import std.string : toStringz;
        return FreeImage_Load(format, path.toStringz, option);
    }

}
