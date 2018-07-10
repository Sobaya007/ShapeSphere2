module sbylib.wrapper.freeimage.Image;


class Image {

    import derelict.freeimage.freeimage;
    import sbylib.wrapper.freeimage.Constants;

    private FIBITMAP* bitmap;

    this(int width, int height, int bpp) {
        this(FreeImage_Allocate(width, height, bpp));
    }

    package this(FIBITMAP* bitmap)
        in(bitmap !is null)
    {
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

    uint getBPP() {
        return FreeImage_GetBPP(bitmap);
    }

    ubyte* getBits() {
        return FreeImage_GetBits(bitmap);
    }

    ubyte[] getData() {
        return getBits[0..getWidth() * getHeight() * getBPP() / 8];
    }

    ImageType getImageType() {
        import std.conv : to;
        return FreeImage_GetImageType(bitmap).to!ImageType;
    }

    void save(string path) {
        import std.path;
        switch(path.extension) {
            case ".bmp":
                saveAsBmp(path);
                break;
            case ".exr":
                saveAsExr(path);
                break;
            case ".jpeg":
            case ".jpg":
                saveAsExr(path);
                break;
            case ".png":
                saveAsPng(path);
                break;
            case ".tiff":
                saveAsTiff(path);
                break;
            default:
                assert(false, "Unrecognized format '" ~ path.extension ~ "'");
        }
    }

    void saveAsBmp(string path, bool rle = false) {
        int option;
        if (rle) option = BMP_SAVE_RLE;
        else option = BMP_DEFAULT;

        save(ImageFormat.Bmp, path, option);
    }

    void saveAsExr(string path, bool saveAs32Bit = false, ExrSaveOption op = ExrSaveOption.None) {
        int option = EXR_DEFAULT;
        if (saveAs32Bit) option |= EXR_FLOAT;
        option |= op;

        save(ImageFormat.Exr, path, option);
    }

    void saveAsJ2k(string path, int rate = J2K_DEFAULT)
        in(1 <= rate && rate <= 512)
    {
        save(ImageFormat.J2k, path, rate);
    }

    void saveAsJp2(string path, int rate = JP2_DEFAULT)
        in(1 <= rate && rate <= 512)
    {
        save(ImageFormat.Jp2, path, rate);
    }

    void saveAsJpeg(string path, int quality, JpegSaveSubsamplingOption subsamplingOption = JpegSaveSubsamplingOption.Subsampling420, bool progressive = false)
        in(0 <= quality && quality <= 100)
    {
        int option = quality;
        option |= subsamplingOption;
        if (progressive) option |= JPEG_PROGRESSIVE;
        save(ImageFormat.Jpeg, path, option);
    }

    void saveAsJpeg(string path, JpegSaveQualityOption quality = JpegSaveQualityOption.Default, JpegSaveSubsamplingOption subsamplingOption = JpegSaveSubsamplingOption.Subsampling420, bool progressive = false) {
        int option = quality | subsamplingOption;
        if (progressive) option |= JPEG_PROGRESSIVE;
        save(ImageFormat.Jpeg, path, option);
    }

    void saveAsPng(string path, PngSaveOption op = PngSaveOption.Default, bool interlace = false) {
        int option = op;
        if (interlace) option |= PNG_INTERLACED;

        save(ImageFormat.Png, path, option);
    }

    void saveAsPbm(string path, PnmSaveOption option = PnmSaveOption.Default) {
        save(ImageFormat.Pbm, path, option);
    }

    void saveAsPgm(string path, PnmSaveOption option = PnmSaveOption.Default) {
        save(ImageFormat.Pgm, path, option);
    }

    void saveAsPpm(string path, PnmSaveOption option = PnmSaveOption.Default) {
        save(ImageFormat.Ppm, path, option);
    }

    void saveAsTiff(string path, TiffSaveOption option = TiffSaveOption.Default) {
        save(ImageFormat.Tiff, path, option);
    }

    void save(ImageFormat fmt, string path, int option = 0) {
        import std.string : toStringz;
        import std.format;

        auto saveResult = FreeImage_Save(fmt, bitmap, path.toStringz, option);

        assert(saveResult, format!"Failed to Save '%s'"(path));
    }
}
