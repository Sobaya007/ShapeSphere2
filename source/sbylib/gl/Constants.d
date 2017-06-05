module sbylib.gl.Constants;

import derelict.opengl;

enum Prim {
    Triangle = GL_TRIANGLES,
    TriangleStrip = GL_TRIANGLE_STRIP,
    TriangleFan = GL_TRIANGLE_FAN, 
    Line = GL_LINES
}

enum GpuSendFrequency {
    Stream = GL_STREAM_DRAW,
    Dynamic = GL_DYNAMIC_DRAW,
    Static = GL_STATIC_DRAW,
}

enum BlendEquation {
    Add = GL_FUNC_ADD,
    Subtract = GL_FUNC_SUBTRACT,
    SubtractReverse = GL_FUNC_REVERSE_SUBTRACT,
    Min = GL_MIN,
    Max = GL_MAX
}

enum BlendFunc {
    One = GL_ONE,
    Zero = GL_ZERO,
    SrcAlpha = GL_SRC_ALPHA,
    DstAlpha = GL_DST_ALPHA,
    SrcColor = GL_SRC_COLOR,
    DstColor = GL_DST_COLOR,
    OneMinusSrcAlpha = GL_ONE_MINUS_SRC_ALPHA,
    OneMinusDstAlpha = GL_ONE_MINUS_DST_ALPHA,
    OneMinusSrcColor = GL_ONE_MINUS_SRC_COLOR,
    OneMinusDstColor = GL_ONE_MINUS_DST_COLOR,
}

enum StencilFunc {
    Always = GL_ALWAYS,
    Never = GL_NEVER,
    Less = GL_LESS,
    Greater = GL_GREATER,
    LessEqual = GL_LEQUAL,
    GreaterEqual = GL_GEQUAL,
    Equal = GL_EQUAL,
    NotEqual = GL_NOTEQUAL
}

enum StencilWrite {
    Zero = GL_ZERO, //0にする
    Keep = GL_KEEP, //そのままにする
    Replace = GL_REPLACE, //evalStencilにする
    Invert = GL_INVERT, //ビット列を反転する
    Increment = GL_INCR, //+1する
    IncrementWrap = GL_INCR_WRAP, //+1して最大値になったら0にする
    Decrement = GL_DECR, //-1する
    DecrementWrap = GL_DECR_WRAP, //-1して負になったら最大値にする
}

enum ImageType {
    R = GL_RED,
    RG = GL_RG,
    RGB = GL_RGB,
    RGBA = GL_RGBA,
    Depth = GL_DEPTH_COMPONENT24,
    DepthStencil = GL_DEPTH_STENCIL
};
