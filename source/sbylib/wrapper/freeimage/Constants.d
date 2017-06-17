module sbylib.wrapper.freeimage.Constants;

import derelict.freeimage.freeimage;

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
