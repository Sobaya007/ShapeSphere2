module sbylib.wrapper.freeimage.Constants;

import derelict.freeimage.freeimage;
import std.variant;

enum ImageType {
    Unknown = FIT_UNKNOWN,
    Bitmap = FIT_BITMAP,
    Uint16 = FIT_UINT16,
    Int16 = FIT_INT16,
    Uint32 = FIT_UINT32,
    Int32 = FIT_INT32,
    Float = FIT_FLOAT,
    Double = FIT_DOUBLE,
    Complex = FIT_COMPLEX,
    Rgb16 = FIT_RGB16,
    Rgba16 = FIT_RGBA16,
    Rgbf = FIT_RGBF,
    Rgbaf = FIT_RGBAF
}

enum ImageFormat {
    Unknown = FIF_UNKNOWN,
    Bmp = FIF_BMP,
    Cut = FIF_CUT,
    Dds = FIF_DDS,
    Exr = FIF_EXR,
    FaxG3 = FIF_FAXG3,
    Gif = FIF_GIF,
    Hdr = FIF_HDR,
    Ico = FIF_ICO,
    Iff = FIF_IFF,
    J2k = FIF_J2K,
    Jng = FIF_JNG,
    Jp2 = FIF_JP2,
    Jpeg = FIF_JPEG,
    Koala = FIF_KOALA,
    Mng = FIF_MNG,
    Pbm = FIF_PBM,
    PbmRaw = FIF_PBMRAW,
    Pcd = FIF_PCD,
    Pcx = FIF_PCX,
    Pfm = FIF_PFM,
    Pgm = FIF_PGM,
    PgmRaw = FIF_PGMRAW,
    Pict = FIF_PICT,
    Png = FIF_PNG,
    Ppm = FIF_PPM,
    PpmRaw = FIF_PPMRAW,
    Psd = FIF_PSD,
    Ras = FIF_RAS,
    Raw = FIF_RAW,
    Sgi = FIF_SGI,
    Targa = FIF_TARGA,
    Tiff = FIF_TIFF,
    Wbmp = FIF_WBMP,
    Xbm = FIF_XBM,
    Xpm = FIF_XPM
}

enum GifLoadOption {
    Default = GIF_DEFAULT,
    Load256 = GIF_LOAD256,
    PlayBack = GIF_PLAYBACK,
}

enum IcoLoadOption {
    Default = 0,
    MakeAlpha = ICO_MAKEALPHA,
}

enum JpegLoadOption {
    Default = JPEG_DEFAULT,
    Fast = JPEG_FAST,
    Accurate = JPEG_ACCURATE,
}

enum PcdLoadOption {
    Default = PCD_DEFAULT,
    Base = PCD_BASE,
    BaseDiv4 = PCD_BASEDIV4,
    BaseDiv16 = PCD_BASEDIV16,
}

enum PngLoadOption {
    Default = 0,
    PngIgnoreGamma = PNG_IGNOREGAMMA,
}

enum RawLoadOption {
    Default = RAW_DEFAULT,
    Preview = RAW_PREVIEW,
    Display = RAW_DISPLAY,
}

enum ExrSaveOption {
    None = EXR_NONE,
    Zip = EXR_ZIP,
    Piz = EXR_PIZ,
    Pxr24 = EXR_PXR24,
    B44 = EXR_B44,
    LC = EXR_LC,
}

enum JpegSaveQualityOption {
    Default = JPEG_DEFAULT,
    Superb = JPEG_QUALITYSUPERB,
    Good = JPEG_QUALITYGOOD,
    Normal = JPEG_QUALITYNORMAL,
    Average = JPEG_QUALITYAVERAGE,
    Bad = JPEG_QUALITYBAD,
}

enum JpegSaveSubsamplingOption {
    Subsampling411 = JPEG_SUBSAMPLING_411,
    Subsampling420 = JPEG_SUBSAMPLING_420,
    Subsampling422 = JPEG_SUBSAMPLING_422,
    Subsampling444 = JPEG_SUBSAMPLING_444,
}

enum PngSaveOption {
    Default = PNG_DEFAULT,
    ZBestSpeed = PNG_Z_BEST_SPEED,
    ZDefaultCompression = PNG_Z_DEFAULT_COMPRESSION,
    ZBestCompression = PNG_Z_BEST_COMPRESSION,
    ZNoCompression = PNG_Z_NO_COMPRESSION,
}

enum PnmSaveOption {
    Default = PNM_DEFAULT,
    SaveRaw = PNM_SAVE_RAW,
    SaveAscii = PNM_SAVE_ASCII
}

enum TiffSaveOption {
    Default = TIFF_DEFAULT,
    CMYK = TIFF_CMYK,
    PackBits = TIFF_PACKBITS,
    Deflate = TIFF_DEFLATE,
    AdobeDeflate = TIFF_ADOBE_DEFLATE,
    None = TIFF_NONE,
    CCITT_Fax3 = TIFF_CCITTFAX3,
    CCITT_Fax4 = TIFF_CCITTFAX4,
    LZW = TIFF_LZW,
    Jpeg = TIFF_JPEG,
}
