module sbylib.wrapper.gl.Constants;

import derelict.opengl;

enum ClearMode {
    Color = GL_COLOR_BUFFER_BIT,
    Depth = GL_DEPTH_BUFFER_BIT,
    Stencil = GL_STENCIL_BUFFER_BIT
};


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

enum BlendFactor {
    Zero = GL_ZERO,
    One = GL_ONE,
    SrcAlpha = GL_SRC_ALPHA,
    DstAlpha = GL_DST_ALPHA,
    SrcColor = GL_SRC_COLOR,
    DstColor = GL_DST_COLOR,
    OneMinusSrcAlpha = GL_ONE_MINUS_SRC_ALPHA,
    OneMinusDstAlpha = GL_ONE_MINUS_DST_ALPHA,
    OneMinusSrcColor = GL_ONE_MINUS_SRC_COLOR,
    OneMinusDstColor = GL_ONE_MINUS_DST_COLOR,
    ConstantColor = GL_CONSTANT_COLOR,
    OneMinusConstantColor = GL_ONE_MINUS_CONSTANT_COLOR,
    ConstantAlpha = GL_CONSTANT_ALPHA
}

enum TestFunc {
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

enum ImageInternalFormat {
    R = GL_RED,
    RG = GL_RG,
    RGB = GL_RGB,
    RGBA = GL_RGBA,
    Depth = GL_DEPTH_COMPONENT24,
    DepthStencil = GL_DEPTH_STENCIL
};

enum ImageFormat {
    R = GL_RED,
    RG = GL_RG,
    RGB = GL_RGB,
    BGR = GL_BGR,
    RGBA = GL_RGBA,
    BGRA = GL_BGRA,
    Depth = GL_DEPTH_COMPONENT24,
    DepthStencil = GL_DEPTH_STENCIL
}

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

enum BufferAccess {
    Read = GL_READ_ONLY,
    Write = GL_WRITE_ONLY,
    Both = GL_READ_WRITE
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

enum Capability {
    Blend = GL_BLEND,
    ClipDistance = GL_CLIP_DISTANCE0,
    ColorLogicOp = GL_COLOR_LOGIC_OP,
    CullFace = GL_CULL_FACE,
    DebugOutput = GL_DEBUG_OUTPUT,
    DebugOutputSynchronous = GL_DEBUG_OUTPUT_SYNCHRONOUS,
    DepthClamp = GL_DEPTH_CLAMP,
    DepthTest = GL_DEPTH_TEST,
    Dither = GL_DITHER,
    LineSmooth = GL_LINE_SMOOTH,
    MultiSample = GL_MULTISAMPLE,
    PolygonOffsetFill = GL_POLYGON_OFFSET_FILL,
    PolygonOffsetLine = GL_POLYGON_OFFSET_LINE,
    PolygonOffsetPoint = GL_POLYGON_OFFSET_POINT,
    PolygonSmooth = GL_POLYGON_SMOOTH,
    PrimitiveRestart = GL_PRIMITIVE_RESTART,
    PrimitiveRestartFixedIndex = GL_PRIMITIVE_RESTART_FIXED_INDEX,
    RasterizerDiscard = GL_RASTERIZER_DISCARD,
    SampleAlphaToCoverage = GL_SAMPLE_ALPHA_TO_COVERAGE,
    SampleAlphaToOne = GL_SAMPLE_ALPHA_TO_ONE,
    SampleCoverage = GL_SAMPLE_COVERAGE,
    SampleShading = GL_SAMPLE_SHADING,
    SampleMask = GL_SAMPLE_MASK,
    ScissorTest = GL_SCISSOR_TEST,
    StencilTest = GL_STENCIL_TEST,
    TextureCubeMapSeamless = GL_TEXTURE_CUBE_MAP_SEAMLESS,
    ProgramPointSize = GL_PROGRAM_POINT_SIZE
};

enum FaceMode {
    Front = GL_FRONT,
    Back = GL_BACK,
    FrontBack = GL_FRONT_AND_BACK
}

enum PolygonMode {
    Fill = GL_FILL,
    Line = GL_LINE,
    Point = GL_POINT,
    None = 114514
}

enum TextureTarget {
    Tex1DArray = GL_TEXTURE_1D_ARRAY,
    Tex2D = GL_TEXTURE_2D,
    Rect = GL_TEXTURE_RECTANGLE,
    CubePosX = GL_TEXTURE_CUBE_MAP_POSITIVE_X,
    CubePosY = GL_TEXTURE_CUBE_MAP_POSITIVE_Y,
    CubePosZ = GL_TEXTURE_CUBE_MAP_POSITIVE_Z,
    CubeNegX = GL_TEXTURE_CUBE_MAP_NEGATIVE_X,
    CubeNegY = GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,
    CubeNegZ = GL_TEXTURE_CUBE_MAP_NEGATIVE_Z,
    Proxy1DArray = GL_PROXY_TEXTURE_1D_ARRAY,
    Proxy2D = GL_PROXY_TEXTURE_2D,
    ProxyRect = GL_PROXY_TEXTURE_RECTANGLE,
    ProxyCube = GL_PROXY_TEXTURE_CUBE_MAP
}

enum TextureParamName {
    DepthStencilMode = GL_DEPTH_STENCIL_TEXTURE_MODE,
    BaseLevel = GL_TEXTURE_BASE_LEVEL,
    CompareFunc = GL_TEXTURE_COMPARE_FUNC,
    CompareMode = GL_TEXTURE_COMPARE_MODE,
    LodBias = GL_TEXTURE_LOD_BIAS,
    MinFilter = GL_TEXTURE_MIN_FILTER,
    MagFilter = GL_TEXTURE_MAG_FILTER,
    MinLod = GL_TEXTURE_MIN_LOD,
    MaxLod = GL_TEXTURE_MAX_LOD,
    MaxLevel = GL_TEXTURE_MAX_LEVEL,
    SwizzleR = GL_TEXTURE_SWIZZLE_R,
    SwizzleG = GL_TEXTURE_SWIZZLE_G,
    SwizzleB = GL_TEXTURE_SWIZZLE_B,
    SwizzleA = GL_TEXTURE_SWIZZLE_A,
    WrapS = GL_TEXTURE_WRAP_S,
    WrapT = GL_TEXTURE_WRAP_T,
    WrapR = GL_TEXTURE_WRAP_R,
}

enum DepthStencilMode {
    Depth = GL_DEPTH_COMPONENT,
    Stencil = GL_STENCIL_COMPONENTS
}

enum TextureFilter {
    Nearest = GL_NEAREST,
    Linear = GL_LINEAR
}

enum TextureWrap {
    Repeat = GL_REPEAT,
    ClampToEdge = GL_CLAMP_TO_EDGE,
    ClampToBorder = GL_CLAMP_TO_BORDER,
    MirroredRepeat = GL_MIRRORED_REPEAT
}

enum GlErrorType {
    NoError = GL_NO_ERROR,
    InvalidEnum = GL_INVALID_ENUM,
    InvalidValue = GL_INVALID_VALUE,
    InvaliedOperation = GL_INVALID_OPERATION,
    OutOfMemory = GL_OUT_OF_MEMORY
}
