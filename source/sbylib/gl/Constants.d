module sbylib.gl.Constants;

import derelict.opengl;

enum Prim {
    Triangle = GL_TRIANGLES,
    TriangleStrip = GL_TRIANGLE_STRIP,
    TriangleFan = GL_TRIANGLE_FAN, 
    Line = GL_LINES
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

enum ShaderType {
    Vertex = GL_VERTEX_SHADER,
    Fragment = GL_FRAGMENT_SHADER,
    Geometry = GL_GEOMETRY_SHADER
}

enum ShaderParamName {
    ShaderType = GL_SHADER_TYPE,
    DeleteStatus = GL_DELETE_STATUS,
    CompileStatus = GL_COMPILE_STATUS,
    InfoLogLength = GL_INFO_LOG_LENGTH,
    ShaderSourceLength = GL_SHADER_SOURCE_LENGTH
}

enum ProgramParamName {
    DeleteStatus = GL_DELETE_STATUS,
    LinkStatus = GL_LINK_STATUS,
    ValidateStatus = GL_VALIDATE_STATUS,
    InfoLogLength = GL_INFO_LOG_LENGTH,
    AttachedShaders = GL_ATTACHED_SHADERS,
    ActiveAtomicCounterBuffers = GL_ACTIVE_ATOMIC_COUNTER_BUFFERS,
    ActiveAttributes = GL_ACTIVE_ATTRIBUTES,
    ActiveAttributesMaxLength = GL_ACTIVE_ATTRIBUTE_MAX_LENGTH,
    ActiveUniforms = GL_ACTIVE_UNIFORMS,
    ActiveUniformMaxLength = GL_ACTIVE_UNIFORM_MAX_LENGTH,
    ProgramBinaryLength = GL_PROGRAM_BINARY_LENGTH,
    ComputeWorkGroupSize = GL_COMPUTE_WORK_GROUP_SIZE,
    TransformFeedbackBufferMode = GL_TRANSFORM_FEEDBACK_BUFFER_MODE,
    TransformFeedbackVaryingMaxLength = GL_TRANSFORM_FEEDBACK_VARYING_MAX_LENGTH,
    GeometryVerticesOut = GL_GEOMETRY_VERTICES_OUT,
    GeometryInputType = GL_GEOMETRY_INPUT_TYPE,
    GeometryOutputType = GL_GEOMETRY_OUTPUT_TYPE
}

enum BufferType {
    Array = GL_ARRAY_BUFFER,
    AtomicCounter = GL_ATOMIC_COUNTER_BUFFER,
    CopyRead = GL_COPY_READ_BUFFER,
    CopyWrite = GL_COPY_WRITE_BUFFER,
    DispatchIndirect = GL_DISPATCH_INDIRECT_BUFFER,
    DrawIndirect = GL_DRAW_INDIRECT_BUFFER,
    ElementArray = GL_ELEMENT_ARRAY_BUFFER,
    PixelPack = GL_PIXEL_PACK_BUFFER,
    PixelUnpack = GL_PIXEL_UNPACK_BUFFER,
    Query = GL_QUERY_BUFFER,
    ShaderStorage = GL_SHADER_STORAGE_BUFFER,
    Texture = GL_TEXTURE_BUFFER,
    TransformFeedback = GL_TRANSFORM_FEEDBACK_BUFFER,
    Uniform = GL_UNIFORM_BUFFER
}

enum BufferUsage {
    Stream = GL_STREAM_DRAW,
    Dynamic = GL_DYNAMIC_DRAW,
    Static = GL_STATIC_DRAW,
}


enum FrameBufferBindType {
    Read = GL_READ_FRAMEBUFFER,
    Write = GL_DRAW_FRAMEBUFFER,
    Both = GL_FRAMEBUFFER
}

enum FrameBufferAttachType {
    Color0 = GL_COLOR_ATTACHMENT0,
    Color1 = GL_COLOR_ATTACHMENT1,
    Color2 = GL_COLOR_ATTACHMENT2,
    Depth = GL_DEPTH_ATTACHMENT,
    Stencil = GL_STENCIL_ATTACHMENT,
    DepthStencil = GL_DEPTH_STENCIL_ATTACHMENT
}

enum RenderBufferBindType {
    Both = GL_RENDERBUFFER //リファレンス曰く、これしかない。草。
}

enum GLType {
    Byte = GL_BYTE,
    Ubyte = GL_UNSIGNED_BYTE,
    Short = GL_SHORT,
    Ushort = GL_UNSIGNED_SHORT,
    Int = GL_INT,
    Uint = GL_UNSIGNED_INT,
    HalfFloat = GL_HALF_FLOAT,
    Float = GL_FLOAT,
    Double = GL_DOUBLE,
    Fixed = GL_FIXED
}
