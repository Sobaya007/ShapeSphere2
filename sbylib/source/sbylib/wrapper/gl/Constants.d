module sbylib.wrapper.gl.Constants;

import derelict.opengl;

alias VertexArrayID = uint;
alias BufferID = uint;
alias RenderbufferID = uint;
alias FramebufferID = uint;
alias TextureID = uint;
alias ProgramID = uint;
alias ShaderID = uint;
alias AttribLoc = uint;
alias UniformLoc = uint;

enum BufferBit {
    Color = GL_COLOR_BUFFER_BIT,
    Depth = GL_DEPTH_BUFFER_BIT,
    Stencil = GL_STENCIL_BUFFER_BIT
};

alias ClearMode = BufferBit;

enum Prim {
    Triangle = GL_TRIANGLES,
    TriangleStrip = GL_TRIANGLE_STRIP,
    TriangleFan = GL_TRIANGLE_FAN, 
    Point = GL_POINTS,
    Line = GL_LINES,
    LineLoop = GL_LINE_LOOP,
    LineStrip = GL_LINE_STRIP
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
    RGB8 = GL_RGB8,
    RGBA = GL_RGBA,
    RGBA16F = GL_RGBA16F,
    RGBA32F = GL_RGBA32F,
    Depth = GL_DEPTH_COMPONENT24,
    Stencil = GL_STENCIL_INDEX8,
    DepthStencil = GL_DEPTH_STENCIL
};

enum ImageFormat {
    R = GL_RED,
    RG = GL_RG,
    RGB = GL_RGB,
    BGR = GL_BGR,
    RGBA = GL_RGBA,
    BGRA = GL_BGRA,
    Depth = GL_DEPTH_COMPONENT,
    DepthStencil = GL_DEPTH_STENCIL,
}

enum ShaderType {
    Vertex = GL_VERTEX_SHADER,
    Fragment = GL_FRAGMENT_SHADER,
    Geometry = GL_GEOMETRY_SHADER,
    Compute = GL_COMPUTE_SHADER
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

enum FramebufferBindType {
    Read = GL_READ_FRAMEBUFFER,
    Write = GL_DRAW_FRAMEBUFFER,
    Both = GL_FRAMEBUFFER
}

enum FramebufferAttachType {
    Color0 = GL_COLOR_ATTACHMENT0,
    Color1 = GL_COLOR_ATTACHMENT1,
    Color2 = GL_COLOR_ATTACHMENT2,
    Depth = GL_DEPTH_ATTACHMENT,
    Stencil = GL_STENCIL_ATTACHMENT,
    DepthStencil = GL_DEPTH_STENCIL_ATTACHMENT
}

enum RenderbufferBindType {
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
    InvalidOperation = GL_INVALID_OPERATION,
    InvalidFramebufferOperation = GL_INVALID_FRAMEBUFFER_OPERATION,
    OutOfMemory = GL_OUT_OF_MEMORY
}

enum FramebufferStatus {
    Complete = GL_FRAMEBUFFER_COMPLETE,
    Undefined = GL_FRAMEBUFFER_UNDEFINED,
    IncompleteAttachment = GL_FRAMEBUFFER_INCOMPLETE_ATTACHMENT,
    IncompleteMissingAttachment = GL_FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT,
    IncompleteDrawBuffer = GL_FRAMEBUFFER_INCOMPLETE_DRAW_BUFFER,
    IncompleteReadBuffer = GL_FRAMEBUFFER_INCOMPLETE_READ_BUFFER,
    Unsupported = GL_FRAMEBUFFER_UNSUPPORTED,
    IncompleteMultisample = GL_FRAMEBUFFER_INCOMPLETE_MULTISAMPLE,
    IncompleteLayerTargets = GL_FRAMEBUFFER_INCOMPLETE_LAYER_TARGETS

}

enum PixelAlignType {
    Pack = GL_PACK_ALIGNMENT,
    Unpack = GL_UNPACK_ALIGNMENT
}

enum ParamName {
    ActiveTexture = GL_ACTIVE_TEXTURE,
    AliasedLineWidthRange = GL_ALIASED_LINE_WIDTH_RANGE,
    ArrayBufferBinding = GL_ARRAY_BUFFER_BINDING,
    Blend = GL_BLEND,
    //BlendColor = GL_BLEND_COLOR,
    BlendDstAlpha = GL_BLEND_DST_ALPHA,
    BlendDstRgb = GL_BLEND_DST_RGB,
    BlendEquationRgb = GL_BLEND_EQUATION_RGB,
    BlendEquationAlpha = GL_BLEND_EQUATION_ALPHA,
    BlendSrcAlpha = GL_BLEND_SRC_ALPHA,
    BlendSrcRgb = GL_BLEND_SRC_RGB,
    ClearColor = GL_COLOR_CLEAR_VALUE,
    ColorLogidcOp = GL_COLOR_LOGIC_OP,
    ColorWriteMask = GL_COLOR_WRITEMASK,
    CompressedTextureFormats = GL_COMPRESSED_TEXTURE_FORMATS,
    MaxComputeShaderStorageBlocks = GL_MAX_COMPUTE_SHADER_STORAGE_BLOCKS,
    MaxCombinedShaderStorageBlocks = GL_MAX_COMBINED_SHADER_STORAGE_BLOCKS,
    MaxComputeUniformBlocks = GL_MAX_COMPUTE_UNIFORM_BLOCKS,
    MaxComputeTextureImageUnits = GL_MAX_COMPUTE_TEXTURE_IMAGE_UNITS,
    MaxComputeUniformComponents = GL_MAX_COMPUTE_UNIFORM_COMPONENTS,
    MaxComputeAtomicCounters = GL_MAX_COMPUTE_ATOMIC_COUNTERS,
    MaxComputeAtomicCounterBuffers = GL_MAX_COMPUTE_ATOMIC_COUNTER_BUFFERS,
    MaxCombinedComputeUniformComponents = GL_MAX_COMBINED_COMPUTE_UNIFORM_COMPONENTS,
    MaxComputeWorkGroupInvocations = GL_MAX_COMPUTE_WORK_GROUP_INVOCATIONS,
    MaxComputeWorkGroupCount = GL_MAX_COMPUTE_WORK_GROUP_COUNT,
    MaxComputeWorkGroupSize = GL_MAX_COMPUTE_WORK_GROUP_SIZE,
    DispatchIndirectBufferBinding = GL_DISPATCH_INDIRECT_BUFFER_BINDING,
    DispatchIndirectBuffer = GL_DISPATCH_INDIRECT_BUFFER,
    MaxDebugGroupStackDepth = GL_MAX_DEBUG_GROUP_STACK_DEPTH,
    DebugGrupStackDepth = GL_DEBUG_GROUP_STACK_DEPTH,
    ContextFlags = GL_CONTEXT_FLAGS,
    CullFace = GL_CULL_FACE,
    CullFaceMode = GL_CULL_FACE_MODE,
    CurrentProgram = GL_CURRENT_PROGRAM,
    DepthClearValue = GL_DEPTH_CLEAR_VALUE,
    DepthFunc = GL_DEPTH_FUNC,
    DepthRange = GL_DEPTH_RANGE,
    DepthTest = GL_DEPTH_TEST,
    DepthWriteMask = GL_DEPTH_WRITEMASK,
    Dither = GL_DITHER,
    DoubleBuffer = GL_DOUBLEBUFFER,
    DrawBuffer = GL_DRAW_BUFFER,
    //DrawBuffer[i]
    DrawFramebufferBinding = GL_DRAW_FRAMEBUFFER_BINDING,
    ReadFramebufferBinding = GL_READ_FRAMEBUFFER_BINDING,
    ElementArrayBufferBinding = GL_ELEMENT_ARRAY_BUFFER_BINDING,
    FragmentShaderDerivativeHint = GL_FRAGMENT_SHADER_DERIVATIVE_HINT,
    ImplementationColorReadFormat = GL_IMPLEMENTATION_COLOR_READ_FORMAT,
    ImplementationColorReadType = GL_IMPLEMENTATION_COLOR_READ_TYPE,
    LineSmooth = GL_LINE_SMOOTH,
    LineSmoothHint = GL_LINE_SMOOTH_HINT,
    LineWidth = GL_LINE_WIDTH,
    LayerProvokingVertex = GL_LAYER_PROVOKING_VERTEX,
    LogicOpMode = GL_LOGIC_OP_MODE,
    MajorVersion = GL_MAJOR_VERSION,
    Max3dTextureSize = GL_MAX_3D_TEXTURE_SIZE,
    MaxArrayTextureLayers = GL_MAX_ARRAY_TEXTURE_LAYERS,
    MaxClipDistances = GL_MAX_CLIP_DISTANCES,
    MaxColorTextureSamples = GL_MAX_COLOR_TEXTURE_SAMPLES,
    MaxCombinedAtomicCounters = GL_MAX_COMBINED_ATOMIC_COUNTERS,
    MaxCombinedFragmentUnifromComponents = GL_MAX_COMBINED_FRAGMENT_UNIFORM_COMPONENTS,
    MaxCombinedGeometryUniformComponents = GL_MAX_COMBINED_GEOMETRY_UNIFORM_COMPONENTS,
    MaxCombinedTextureImageUnits = GL_MAX_COMBINED_TEXTURE_IMAGE_UNITS,
    MaxCombinedUniformBlocks = GL_MAX_COMBINED_UNIFORM_BLOCKS,
    MaxCombinedVertexUniformComponents = GL_MAX_COMBINED_VERTEX_UNIFORM_COMPONENTS,
    MaxCubeMapTextureSize = GL_MAX_CUBE_MAP_TEXTURE_SIZE,
    MaxDepthTextureSamples = GL_MAX_DEPTH_TEXTURE_SAMPLES,
    MaxDrawBuffers = GL_MAX_DRAW_BUFFERS,
    MaxDualSourceDrawBuffers = GL_MAX_DUAL_SOURCE_DRAW_BUFFERS,
    MaxElementsIndices = GL_MAX_ELEMENTS_INDICES,
    MaxElementsVertices = GL_MAX_ELEMENTS_VERTICES,
    MaxFragmentAtomicCounters = GL_MAX_FRAGMENT_ATOMIC_COUNTERS,
    MaxFragmentShaderStorageBlocks = GL_MAX_FRAGMENT_SHADER_STORAGE_BLOCKS,
    MaxFragmentInputComponents = GL_MAX_FRAGMENT_INPUT_COMPONENTS,
    MaxFragmentUniformComponents = GL_MAX_FRAGMENT_UNIFORM_COMPONENTS,
    MaxFragmentUniformVectors = GL_MAX_FRAGMENT_UNIFORM_VECTORS,
    MaxFragmentUniformBlocks = GL_MAX_FRAGMENT_UNIFORM_BLOCKS,
    MaxFramebufferWidth = GL_MAX_FRAMEBUFFER_WIDTH,
    MaxFramebufferHeight = GL_MAX_FRAMEBUFFER_HEIGHT,
    MaxFramebufferLayers = GL_MAX_FRAMEBUFFER_LAYERS,
    MaxFramebufferSamples = GL_MAX_FRAMEBUFFER_SAMPLES,
    MaxGeometryAtomicCounters = GL_MAX_GEOMETRY_ATOMIC_COUNTERS,
    MaxGeometryShaderStorageBlocks = GL_MAX_GEOMETRY_SHADER_STORAGE_BLOCKS,
    MaxGeometryInputComponents = GL_MAX_GEOMETRY_INPUT_COMPONENTS,
    MaxGeometryOutputComponents = GL_MAX_GEOMETRY_OUTPUT_COMPONENTS,
    MaxGeometryTextureImageUnits = GL_MAX_GEOMETRY_TEXTURE_IMAGE_UNITS,
    MaxGeometryUniformBlocks = GL_MAX_GEOMETRY_UNIFORM_BLOCKS,
    MaxGeometryUniformComponents = GL_MAX_GEOMETRY_UNIFORM_COMPONENTS,
    MaxIntegerSamples = GL_MAX_INTEGER_SAMPLES,
    MinMapBufferAlignment = GL_MIN_MAP_BUFFER_ALIGNMENT,
    MaxLabelLength = GL_MAX_LABEL_LENGTH,
    MaxProgramTexelOffset = GL_MAX_PROGRAM_TEXEL_OFFSET,
    MinProgramTexelOffset = GL_MIN_PROGRAM_TEXEL_OFFSET,
    MaxRectangleTextureSize = GL_MAX_RECTANGLE_TEXTURE_SIZE,
    MaxRenderbufferSize = GL_MAX_RENDERBUFFER_SIZE,
    MaxSampleMaskWords = GL_MAX_SAMPLE_MASK_WORDS,
    MaxServerWaitTimeout = GL_MAX_SERVER_WAIT_TIMEOUT,
    MaxShaderStorageBufferBindings = GL_MAX_SHADER_STORAGE_BUFFER_BINDINGS,
    MaxTessControlAtomicCounters = GL_MAX_TESS_CONTROL_ATOMIC_COUNTERS,
    MaxTessEvaluationAtomicCounters = GL_MAX_TESS_EVALUATION_ATOMIC_COUNTERS,
    MaxTessControlShaderStorageBlocks = GL_MAX_TESS_CONTROL_SHADER_STORAGE_BLOCKS,
    MaxTessEvaluationShaderStorageBlocks = GL_MAX_TESS_EVALUATION_SHADER_STORAGE_BLOCKS,
    MaxTextureBufferSize = GL_MAX_TEXTURE_BUFFER_SIZE,
    MaxTextureImageUnits = GL_MAX_TEXTURE_IMAGE_UNITS,
    MaxTextureLodBias = GL_MAX_TEXTURE_LOD_BIAS,
    MaxTextureSize = GL_MAX_TEXTURE_SIZE,
    MaxUniformBufferBindings = GL_MAX_UNIFORM_BUFFER_BINDINGS,
    MaxUniformBlockSize = GL_MAX_UNIFORM_BLOCK_SIZE,
    MaxUniformLocations = GL_MAX_UNIFORM_LOCATIONS,
    MaxVaryingComponents = GL_MAX_VARYING_COMPONENTS,
    MaxVaryingVectors = GL_MAX_VARYING_VECTORS,
    MaxVaryingFloats = GL_MAX_VARYING_FLOATS,

    SmoothLineWidthRange = GL_SMOOTH_LINE_WIDTH_RANGE,

    StencilBackFail = GL_STENCIL_BACK_FAIL,
    StencilBackFunc = GL_STENCIL_BACK_FUNC,
    StencilBackPassDepthFail = GL_STENCIL_BACK_PASS_DEPTH_FAIL,
    StencilBackPassDepthPass = GL_STENCIL_BACK_PASS_DEPTH_PASS,
    StencilBackRef = GL_STENCIL_BACK_REF,
    StencilBackValueMask = GL_STENCIL_BACK_VALUE_MASK,
    StencilBackWriteMask = GL_STENCIL_BACK_WRITEMASK,
    StencilClearValue = GL_STENCIL_CLEAR_VALUE,
    StencilFrontFail = GL_STENCIL_FAIL,
    StencilFrontBunc = GL_STENCIL_FUNC,
    StencilFrontPassDepthFail = GL_STENCIL_PASS_DEPTH_FAIL,
    StencilFrontPassDepthPass = GL_STENCIL_PASS_DEPTH_PASS,
    StencilFrontRef = GL_STENCIL_REF,
    StencilFrontValueMask = GL_STENCIL_VALUE_MASK,
    StencilFrontWriteMask = GL_STENCIL_WRITEMASK,
    StencilTest = GL_STENCIL_TEST
}
