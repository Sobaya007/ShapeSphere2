module sbylib.wrapper.gl.Functions;

import derelict.opengl;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.wrapper.gl.Constants;
import sbylib.utils.Functions;

private class Logger {
    import std.datetime;
    private Duration[][string] data;

    void log(string funcName)(Duration dur) {
        if (funcName !in data) data[funcName] = [];
        data[funcName] ~= dur;
    }

    void save() {
        import std.file : write;
        import std.array;
        import std.algorithm;
        import std.conv : to;
        import std.typecons;
        import std.format;
        import core.time;
        auto text = data.keys.map!((string funcName) {
            auto durs = data[funcName];
            auto s = durs.map!(d => d.total!"usecs").sum;
            return tuple(funcName, s, durs.length);
        })
        .array.sort!((a,b) => a[1] > b[1])
        .map!(t => [
            t[0] ~ ":",
            "\ttotal   : " ~ t[1].to!string,
            "\taverage : " ~ (t[1] / cast(float)t[2]).to!string,
            "\tcount   : " ~ t[2].to!string
        ]).join.join("\n");
        write("gl.log", text);
    }
}

class GlFunction {

    mixin Singleton;

    enum MEASURE_TIME = true;

    static if (MEASURE_TIME) {
        private Logger logger;
    }

    private GlFunctionImpl impl;

    this() {
        this.impl = new GlFunctionImpl;
        static if (MEASURE_TIME) {
            this.logger = new Logger();
        }
    }

    void save() {
        static if (MEASURE_TIME) {
            logger.save();
        }
    }

    template opDispatch(string member) {
        import std.traits : isCallable, Parameters;

        enum Member = "impl." ~ member;

        static if (is(typeof(isCallable!(mixin(Member)))) && isCallable!(mixin(Member))) {
            alias Params = Parameters!(mixin(Member));

            auto opDispatch(Params args) {
                scope(exit) checkError!(member, Params)(args);
                static if (MEASURE_TIME) {
                    import std.datetime.stopwatch;
                    StopWatch sw;
                    sw.start();
                    scope(exit) logger.log!(member)(sw.peek);
                    return mixin(Member ~ "(args)");
                } else {
                    return mixin(Member ~ "(args)");
                }
            }
        } else {
             static if (__traits(isTemplate, mixin(Member))) {
                // some template function
                auto opDispatch(Args...)(Parameters!(mixin(Member~"!(Args)")) args) {
                    enum InstancedMember = Member ~ "!(Args)";
                    scope(exit) checkError!(member ~ "!" ~ Args.stringof, Parameters!(mixin(Member~"!(Args)")))(args);
                    static if (MEASURE_TIME) {
                        import std.datetime.stopwatch;
                        StopWatch sw;
                        sw.start();
                        scope(exit) logger.log!(member ~ "!" ~ Args.stringof)(sw.peek);
                        return mixin(InstancedMember ~ "(args)");
                    } else {
                        return mixin(InstancedMember ~ "(args)");
                    }
                }
            } else {
                static assert(false);
            }
        }
    }
    
    private void checkError(string funcName, Args...)(Args args) {
        debug {
            import sbylib.wrapper.glfw.GLFW;
            import std.conv : to;
            import std.format;
            import std.stdio;
            if (GLFW.hasTerminated) return;
            auto errorCode = glGetError().to!GlErrorType;
            if (errorCode == GlErrorType.NoError) return;
            writeln("args are:");
            foreach (i, arg; args) {
                writeln(Args[i].stringof, " ", arg);
            }
            if (errorCode == GlErrorType.InvalidFramebufferOperation) {
                auto status = glCheckFramebufferStatus(GL_FRAMEBUFFER).to!FramebufferStatus;
                assert(false, format!"%s : %s at %s(%s)"(errorCode, status, funcName, Args.stringof));
            } else {
                assert(false, format!"%s at %s(%s)"(errorCode, funcName, Args.stringof));
            }
        }
    }
} 
class GlFunctionImpl {

    this() {
        // make sure context
        import sbylib.core.Core;
        import sbylib.core.Window;
        static Window window;
        if (window is null) {
            window = Core().getWindow();
            window.makeCurrent();
        }
    }

    void enable(Capability cap) {
        glEnable(cap);
    }

    void disable(Capability cap) {
        glDisable(cap);
    }

    void clear(ClearMode[] mode...) {
        import std.algorithm : reduce;
        glClear(reduce!((a,b)=>a|b)(mode));
    }

    void clearColor(float r, float g, float b, float a) {
        glClearColor(r, g, b, a);
    }

    void clearDepth(double depth) {
        glClearDepth(depth);
    }

    void clearStencil(int stencil) {
        glClearStencil(stencil);
    }

    void colorMask(bool r, bool g, bool b, bool a) {
        glColorMask(r, g, b, a);
    }

    void depthMask(bool mask) {
        glDepthMask(mask);
    }

    void stencilMask(uint mask) {
        glStencilMask(mask);
    }

    void blendFunc(BlendFactor src, BlendFactor dst)  {
        glBlendFunc(src, dst);
    }

    void blendEquation(BlendEquation eq) {
        glBlendEquation(eq);
    }

    void depthFunc(TestFunc func) {
        enable(Capability.DepthTest);
        glDepthFunc(func);
    }

    void stencilFunc(TestFunc test, uint reffer, uint mask) {
        glStencilFunc(test, reffer, mask);
    }

    void stencilOp(StencilWrite sfail, StencilWrite dpfail, StencilWrite pass) {
        glStencilOp(sfail, dpfail, pass);
    }

    void cullFace(FaceMode face) {
        glCullFace(face);
    }

    void polygonMode(FaceMode face, PolygonMode polygon) {
        glPolygonMode(face, polygon);
    }

    void setPixelPackAlign(int alignment)
        in( alignment == 1
        || alignment == 2
        || alignment == 4
        || alignment == 8)
    {
        glPixelStorei(PixelAlignType.Pack, alignment);
    }

    void setPixelUnpackAlign(int alignment)
        in( alignment == 1
        || alignment == 2
        || alignment == 4
        || alignment == 8)
    {
        glPixelStorei(PixelAlignType.Unpack, alignment);
    }

    void genBuffers(uint num, uint* ptr) {
        glGenBuffers(num, ptr);
    }

    void deleteBuffers(uint num, uint* ptr) {
        glDeleteBuffers(num, ptr);
    }

    void bindBuffer(BufferType type, BufferID id) {
        glBindBuffer(type, id);
    }

    void bufferData(Type)(BufferType type, size_t size, Type* data, BufferUsage usage) {
        glBufferData(type, size, data, usage);
    }

    void bufferSubData(Type)(BufferType type, size_t offset, size_t size, Type* data) {
        glBufferSubData(type, offset, size, cast(void*)data);
    }

    void* mapBuffer(BufferType type, BufferAccess access) {
        auto res = glMapBuffer(type, access);
        return res;
    }

    void unmapBuffer(BufferType type) {
        glUnmapBuffer(type);
    }

    void genFramebuffers(uint num, FramebufferID* ptr) {
        glGenFramebuffers(num, ptr);
    }

    void deleteFramebuffers(uint num, FramebufferID* ptr) {
        glDeleteFramebuffers(num, ptr);
    }

    void bindFramebuffer(FramebufferBindType type, FramebufferID id) {
        glBindFramebuffer(type, id);
    }

    void framebufferRenderbuffer(FramebufferBindType bindType, FramebufferAttachType attachType, RenderbufferID renderbufferID) {
        glFramebufferRenderbuffer(bindType, attachType, RenderbufferBindType.Both, renderbufferID);
    }

    void blitFramebuffer(uint srcX0, uint srcY0, uint srcX1, uint srcY1, uint dstX0, uint dstY0, uint dstX1, uint dstY1, TextureFilter filter, BufferBit[] bit...) {
        import std.algorithm : reduce;
        glBlitFramebuffer(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, bit.reduce!((a,b)=>a|b), filter);
    }

    void genRenderbuffers(uint num, RenderbufferID* ptr) {
        glGenRenderbuffers(num, ptr);
    }

    void deleteRenderbuffers(uint num, RenderbufferID* ptr) {
        glDeleteRenderbuffers(num, ptr);
    }

    void bindRenderbuffer(RenderbufferID id) {
        glBindRenderbuffer(RenderbufferBindType.Both, id);
    }

    void renderbufferStorage(uint width, uint height, ImageInternalFormat format) {
        glRenderbufferStorage(RenderbufferBindType.Both, format, width, height);
    }

    void genTextures(uint num, TextureID *ptr) {
        glGenTextures(num, ptr);
    }

    void deleteTextures(uint num, TextureID *ptr) {
        glDeleteTextures(num, ptr);
    }

    void bindTexture(TextureTarget target, TextureID id) {
        glBindTexture(target, id);
    }

    void activeTexture(uint unit) {
        glActiveTexture(GL_TEXTURE0 + unit);
    }

    void texImage2D(Type)(TextureTarget target, uint mipmapLevel, ImageInternalFormat iformat, uint width, uint height, uint border, ImageFormat format, Type *data) {
        glTexImage2D(target, mipmapLevel, iformat, width, height, border, format, GlUtils.getTypeEnum!Type, data);
    }

    void texSubImage2D(Type)(TextureTarget target, uint mipmapLevel, uint offsetX, uint offsetY, uint width, uint height, ImageFormat format, Type *data) {
        glTexSubImage2D(target, mipmapLevel, offsetX, offsetY, width, height, format, GlUtils.getTypeEnum!Type, data);
    }

    void bindImageTexture(uint unit, TextureID id, uint level, bool layered, uint layer, BufferAccess access, ImageInternalFormat format)
        in(unit < GL_MAX_IMAGE_UNITS)
    do {
        glBindImageTexture(unit, id, level, layered, layer, access, format);
    }

    void framebufferTexture2D(FramebufferBindType bindType, FramebufferAttachType attachType, TextureTarget target, TextureID id, uint level) {
        glFramebufferTexture2D(bindType, attachType, target, id, level);
    }

    void getTexImage(Type)(TextureTarget target, uint level, ImageFormat format, Type* ptr) {
        glGetTexImage(target, level, format, GlUtils.getTypeEnum!(Type), ptr);
    }

    void readPixel(Type)(int x, int y, int width, int height, ImageFormat format, Type* ptr) {
        glReadPixels(x, y, width, height, format, GlUtils.getTypeEnum!(Type), ptr);
    }

    void genVertexArrays(uint num, VertexArrayID *ptr) {
        glGenVertexArrays(num, ptr);
    }

    void deleteVertexArray(uint num, VertexArrayID *ptr) {
        glDeleteVertexArrays(num, ptr);
    }

    void bindVertexArray(VertexArrayID id) {
        glBindVertexArray(id);
    }

    void drawArrays(Prim prim, uint offset, uint count) {
        glDrawArrays(prim, offset, count);
    }

    void drawElements(IndexType)(Prim prim, uint length, IndexType* indices) 
        if (is(IndexType == ubyte) || is(IndexType == ushort) || is(IndexType == uint))
    {
        glDrawElements(prim, length, GlUtils.getTypeEnum!(IndexType), cast(void*)indices);
    }

    void setViewport(uint x, uint y, uint w, uint h) {
        glViewport(x,y,w,h);
    }

    void scissor(uint x, uint y, uint width, uint height) {
        enable(Capability.ScissorTest);
        glScissor(x, y, width, height);
    }

    ProgramID createProgram() {
        auto id = glCreateProgram();
        return id;
    }

    void deleteProgram(ProgramID id) {
        glDeleteProgram(id);
    }

    void useProgram(ProgramID id) {
        glUseProgram(id);
    }

    void linkProgram(ProgramID id) {
        glLinkProgram(id);
    }

    void getProgramInfoLog(ProgramID id, int maxLength, int *length, char *infoLog) {
        glGetProgramInfoLog(id, maxLength, length, infoLog);
    }

    void attachShader(ProgramID programID, ShaderID shaderID) {
        glAttachShader(programID, shaderID);
    }

    AttribLoc getAttribLocation(ProgramID programID, string name) {
        import std.string : toStringz;
        auto loc = glGetAttribLocation(programID, name.toStringz);
        return loc;
    }

    UniformLoc getUniformLocation(ProgramID programID, string name) {
        import std.string : toStringz;
        auto loc = glGetUniformLocation(programID, name.toStringz);
        return loc;
    }

    ShaderID createShader(ShaderType type) {
        auto id = glCreateShader(type);
        return id;
    }

    void deleteShader(ShaderID id) {
        glDeleteShader(id);
    }

    void shaderSource(ShaderID id, uint num, char** sourceList, int* lengthList) {
        glShaderSource(id, num, sourceList, lengthList);
    }

    void compileShader(ShaderID id) {
        glCompileShader(id);
    }

    void getShaderInfoLog(ShaderID id, int maxLength, int *length, char *infoLog) {
        glGetShaderInfoLog(id, maxLength, length, infoLog);
    }

    void enableVertexAttribArray(AttribLoc loc) {
        glEnableVertexAttribArray(loc);
    }

    void vertexAttribPointer(Type)(AttribLoc loc, uint size, bool normalized, uint stride, Type* ptr) {
        glVertexAttribPointer(loc, size, GlUtils.getTypeEnum!(Type), normalized, stride, cast(void*)ptr);
    }

    void dispatchCompute(uint groupNumX, uint groupNumY, uint groupNumZ) {
        glDispatchCompute(groupNumX, groupNumY, groupNumZ);
    }

    void uniformBlockBinding(ProgramID programID, uint loc, uint uniformBlockPoint) {
        glUniformBlockBinding(programID, loc, uniformBlockPoint);
    }

    void bindBufferBase(BufferType type, uint blockPoint, BufferID id) {
        glBindBufferBase(type, blockPoint, id);
    }

    UniformLoc getUniformBlockIndex(ProgramID programID, string name) {
        import std.string : toStringz;
        int loc = glGetUniformBlockIndex(programID, name.toStringz);
        return loc;
    }

    void readBuffer(FramebufferAttachType type) {
        glReadBuffer(type);
    }

    void drawBuffer(FramebufferAttachType type) {
        glDrawBuffer(type);
    }

    void drawBuffers(FramebufferAttachType[] types) {
        glDrawBuffers(cast(int)types.length, cast(uint*)types.ptr);
    }

    auto get(T, size_t N)(ParamName param) {
        T[N] data;
        getFunction!T(param, data.ptr);
        return data;
    }

    private template getFunction(T) {
        static if (is(T == int)) {
            alias getFunction = glGetIntegerv;
        } else static if (is(T == float)) {
            alias getFunction = glGetFloatv;
        } else static if (is(T == bool)) {
            alias getFunction = glGetBooleanv;
        } else {
            static assert(false);
        }
    }

    auto getProgram(T, size_t N)(ProgramID programID, ProgramParamName param) {
        T[N] data;
        getProgramFunction!T(programID, param, data.ptr);
        return data;
    }

    private template getProgramFunction(T) {
        static if (is(T == int)) {
            alias getProgramFunction = glGetProgramiv;
        } else static if (is(T == float)) {
            alias getProgramFunction = glGetProgramfv;
        } else {
            static assert(false);
        }
    }

    auto getShader(T, size_t N)(ShaderID shaderID, ShaderParamName param) {
        T[N] data;
        getShaderFunction!T(shaderID, param, data.ptr);
        return data;
    }

    private template getShaderFunction(T) {
        static if (is(T == int)) {
            alias getShaderFunction = glGetShaderiv;
        } else static if (is(T == float)) {
            alias getShaderFunction = glGetShaderfv;
        } else {
            static assert(false);
        }
    }

    void texParameter(T)(TextureTarget target, TextureParamName pname, T value) {
        getTexParamFunction!(T)(target, pname, value);
    }

    private template getTexParamFunction(T) {
        alias getTexParamFunction = glTexParameteri;
    }

    void uniform(T, size_t N)(UniformLoc loc, uint num, T* ptr) 
        if (1 <= N && N <= 4)
    {
        import std.format;
        mixin(format!"glUniform%d%sv"(N, getUniformTypeCharacter!(T)))(loc, num, ptr);
    }

    void uniformMatrix(T, size_t N)(UniformLoc loc, uint num, T* ptr) 
        if (1 <= N && N <= 4)
    {
        import std.format;
        mixin(format!"glUniformMatrix%d%sv"(N, getUniformTypeCharacter!(T)))(loc, num, true, ptr);
    }

    import std.traits : Unqual;
    private template getUniformTypeCharacter(T, S = Unqual!T) 
        if (is(S == bool) || is(S == uint) || is(S == int) || is(S == float))
    {
        static if (is(S == bool)) {
            enum getUniformTypeCharacter = "i";
        } else static if (is(S == int)) {
            enum getUniformTypeCharacter = "i";
        } else static if (is(S == uint)) {
            enum getUniformTypeCharacter = "ui";
        } else static if (is(S == float)) {
            enum getUniformTypeCharacter = "f";
        } else {
            static assert(false);
        }
    }
}

class GlUtils {

static:

    template getTypeEnum(T) {
        static if (is(T == ubyte)) enum GLType getTypeEnum = GLType.Ubyte;
        else static if (is(T == byte)) enum GLType getTypeEnum = GLType.Byte;
        else static if (is(T == ushort)) enum GLType getTypeEnum = GLType.Ushort;
        else static if (is(T == short)) enum GLType getTypeEnum = GLType.Short;
        else static if (is(T == uint)) enum GLType getTypeEnum = GLType.Uint;
        else static if (is(T == int)) enum GLType getTypeEnum = GLType.Int;
        else static if (is(T == float)) enum GLType getTypeEnum = GLType.Float;
        else static if (is(T == double)) enum GLType getTypeEnum = GLType.Double;
        else static assert(false, T.stringof ~ " is an invalid type.");
    }

    void clear(BufferBit[] mode...) {
        import std.algorithm : canFind;
        if (mode.canFind(ClearMode.Color)) colorWrite(true);  //これしないとColorをClearできない
        if (mode.canFind(ClearMode.Depth)) depthWrite(true); //これしないとDepthをClearできない
        if (mode.canFind(ClearMode.Stencil)) stencilWrite(true); //これしないとStencilをClearできない

        GlFunction().clear(mode);
    }

    void clearColor(vec4 color) {
        GlFunction().clearColor(color.r, color.g, color.b, color.a);
    }

    void colorWrite(bool write) {
        GlFunction().colorMask(write, write, write, write);
    }

    void depthWrite(bool write) {
        GlFunction().depthMask(write);
    }

    void stencilWrite(bool write) {
        GlFunction().stencilMask(write ? uint.max : 0);
    }

    void depthTest(bool depthTest) {
        if (depthTest) {
            GlFunction().enable(Capability.DepthTest);
        } else {
            GlFunction().disable(Capability.DepthTest);
        }
    }

    void faceSetting(PolygonMode polygon, FaceMode face = FaceMode.FrontBack) {
        if (polygon == PolygonMode.None) {
            assert(face == FaceMode.FrontBack);
            GlFunction().enable(Capability.CullFace);
            GlFunction().cullFace(FaceMode.FrontBack);
        } else {
            final switch (face) {
            case FaceMode.FrontBack:
                //glDisable(Capability.CullFace);
                GlFunction().polygonMode(FaceMode.FrontBack, polygon);
                break;
            case FaceMode.Front:
                GlFunction().enable(Capability.CullFace);
                GlFunction().cullFace(FaceMode.Back);
                GlFunction().polygonMode(FaceMode.FrontBack, polygon);
                break;
            case FaceMode.Back:
                GlFunction().enable(Capability.CullFace);
                GlFunction().cullFace(FaceMode.Front);
                GlFunction().polygonMode(FaceMode.FrontBack, polygon);
                break;
            }
        }
    }


    void stencil(TestFunc test, int reffer, uint mask, StencilWrite sfail, StencilWrite dpfail, StencilWrite pass) {
        GlFunction().enable(Capability.StencilTest);
        GlFunction().stencilFunc(test, reffer, mask);
        GlFunction().stencilOp(sfail, dpfail, pass);
    }

    int getBitPerPixel(ImageInternalFormat iformat) {
        final switch (iformat) {
            case ImageInternalFormat.R8I:
            case ImageInternalFormat.R8UI:
            case ImageInternalFormat.RG8I:
            case ImageInternalFormat.RG8UI:
            case ImageInternalFormat.RGB8I:
            case ImageInternalFormat.RGB8UI:
            case ImageInternalFormat.RGBA8I:
            case ImageInternalFormat.RGBA8UI:
                return 8;
            case ImageInternalFormat.R16I:
            case ImageInternalFormat.R16UI:
            case ImageInternalFormat.R16F:
            case ImageInternalFormat.RG16I:
            case ImageInternalFormat.RG16UI:
            case ImageInternalFormat.RG16F:
            case ImageInternalFormat.RGB16I:
            case ImageInternalFormat.RGB16UI:
            case ImageInternalFormat.RGB16F:
            case ImageInternalFormat.RGBA16I:
            case ImageInternalFormat.RGBA16UI:
            case ImageInternalFormat.RGBA16F:
                return 16;
            case ImageInternalFormat.R:
            case ImageInternalFormat.R32I:
            case ImageInternalFormat.R32UI:
            case ImageInternalFormat.R32F:
            case ImageInternalFormat.RG:
            case ImageInternalFormat.RG32I:
            case ImageInternalFormat.RG32UI:
            case ImageInternalFormat.RG32F:
            case ImageInternalFormat.RGB:
            case ImageInternalFormat.RGB32I:
            case ImageInternalFormat.RGB32UI:
            case ImageInternalFormat.RGB32F:
            case ImageInternalFormat.RGBA:
            case ImageInternalFormat.RGBA32I:
            case ImageInternalFormat.RGBA32UI:
            case ImageInternalFormat.RGBA32F:
                return 32;
            case ImageInternalFormat.Depth:
                return 24;
            case ImageInternalFormat.Stencil:
                assert(false); //知らん
            case ImageInternalFormat.DepthStencil:
                assert(false); //知らん
        }
        assert(false);
    }

    float[2] getAliasedLineWidthRange() {
        return GlFunction().get!(float, 2)(ParamName.AliasedLineWidthRange);
    }

    float[2] getSmoothLineWidthRange() {
        return GlFunction().get!(float, 2)(ParamName.SmoothLineWidthRange);
    }

    BufferID genBuffer() {
        uint result;
        GlFunction().genBuffers(1, &result);
        return result;
    }

    void deleteBuffer(BufferID id) {
        GlFunction().deleteBuffers(1, &id);
    }

    FramebufferID genFramebuffer() {
        uint result;
        GlFunction().genFramebuffers(1, &result);
        return result;
    }

    void deleteFramebuffer(FramebufferID id) {
        GlFunction().deleteFramebuffers(1, &id);
    }

    RenderbufferID genRenderbuffer() {
        uint result;
        GlFunction().genRenderbuffers(1, &result);
        return result;
    }

    void deleteRenderbuffer(RenderbufferID id) {
        GlFunction().deleteRenderbuffers(1, &id);
    }

    TextureID genTexture() {
        uint result;
        GlFunction().genTextures(1, &result);
        return result;
    }

    void deleteTexture(TextureID id) {
        GlFunction().deleteTextures(1, &id);
    }

    VertexArrayID genVertexArray() {
        uint result;
        GlFunction().genVertexArrays(1, &result);
        return result;
    }

    void deleteVertexArray(VertexArrayID id) {
        GlFunction().deleteVertexArray(1, &id);
    }

    void shaderSource(ShaderID id, string source) {
        import std.string : toStringz;
        auto str = source.toStringz;
        GlFunction().shaderSource(id, 1, cast(char**)&str, null);
    }

    void uniform(T)(UniformLoc loc, T data) {
        import std.traits : Unqual;
        static if (is(Unqual!T == bool)) {
            int d = data;
        } else {
            auto d = data;
        }
        GlFunction().uniform!(typeof(d), 1)(loc, 1, &d);
    }

    void uniform(T, size_t N)(UniformLoc loc, T[N] data) {
        GlFunction().uniform!(T, N)(loc, 1, data.ptr);
    }

    void uniformMatrix(T, size_t N)(UniformLoc loc, T[N*N] data) {
        GlFunction().uniformMatrix!(T, N)(loc, 1, data.ptr);
    }

    FramebufferAttachType getFramebufferColorAttachType(size_t n) {
        final switch (n) {
            case 0: return FramebufferAttachType.Color0;
            case 1: return FramebufferAttachType.Color1;
            case 2: return FramebufferAttachType.Color2;
        }
    }

    bool isColorAttachType(FramebufferAttachType type) {
        switch (type) {
            case FramebufferAttachType.Color0:
            case FramebufferAttachType.Color1:
            case FramebufferAttachType.Color2:
                return true;
            default:
                return false;
        }
    }

    size_t getColorAttachTypeIndex(FramebufferAttachType type) 
        in(isColorAttachType(type))
    {
        switch (type) {
            case FramebufferAttachType.Color0:
                return 0;
            case FramebufferAttachType.Color1:
                return 1;
            case FramebufferAttachType.Color2:
                return 2;
            default:
                assert(false);
        }
    }
}
