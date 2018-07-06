module sbylib.wrapper.gl.Functions;

import derelict.opengl;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.wrapper.gl.Constants;

class GlFunction {
static:

    void enable(Capability cap) {
        glEnable(cap);
        checkError();
    }

    void disable(Capability cap) {
        glDisable(cap);
        checkError();
    }

    void clear(ClearMode[] mode...) {
        import std.algorithm : reduce;
        glClear(reduce!((a,b)=>a|b)(mode));
        checkError();
    }

    void clearColor(float r, float g, float b, float a) {
        glClearColor(r, g, b, a);
        checkError();
    }

    void clearDepth(double depth) {
        glClearDepth(depth);
        checkError();
    }

    void clearStencil(int stencil) {
        glClearStencil(stencil);
        checkError();
    }

    void colorMask(bool r, bool g, bool b, bool a) {
        glColorMask(r, g, b, a);
        checkError();
    }

    void depthMask(bool mask) {
        glDepthMask(mask);
        checkError();
    }

    void stencilMask(uint mask) {
        glStencilMask(mask);
        checkError();
    }

    void blendFunc(BlendFactor src, BlendFactor dst)  {
        glBlendFunc(src, dst);
        checkError();
    }

    void blendEquation(BlendEquation eq) {
        glBlendEquation(eq);
        checkError();
    }

    void depthFunc(TestFunc func) {
        enable(Capability.DepthTest);
        glDepthFunc(func);
        checkError();
    }

    void stencilFunc(TestFunc test, uint reffer, uint mask) {
        glStencilFunc(test, reffer, mask);
        checkError();
    }

    void stencilOp(StencilWrite sfail, StencilWrite dpfail, StencilWrite pass) {
        glStencilOp(sfail, dpfail, pass);
        checkError();
    }

    void cullFace(FaceMode face) {
        glCullFace(face);
        checkError();
    }

    void polygonMode(FaceMode face, PolygonMode polygon) {
        glPolygonMode(face, polygon);
        checkError();
    }

    void setPixelPackAlign(int alignment)
        in( alignment == 1
        || alignment == 2
        || alignment == 4
        || alignment == 8)
    {
        glPixelStorei(PixelAlignType.Pack, alignment);
        checkError();
    }

    void setPixelUnpackAlign(int alignment)
        in( alignment == 1
        || alignment == 2
        || alignment == 4
        || alignment == 8)
    {
        glPixelStorei(PixelAlignType.Unpack, alignment);
        checkError();
    }

    void genBuffers(uint num, uint* ptr) {
        glGenBuffers(num, ptr);
        checkError();
    }

    void deleteBuffers(uint num, uint* ptr) {
        glDeleteBuffers(num, ptr);
        checkError();
    }

    void bindBuffer(BufferType type, BufferID id) {
        glBindBuffer(type, id);
        checkError();
    }

    void bufferData(Type)(BufferType type, size_t size, Type* data, BufferUsage usage) {
        glBufferData(type, size, data, usage);
        checkError();
    }

    void bufferSubData(Type)(BufferType type, size_t offset, size_t size, Type* data) {
        glBufferSubData(type, offset, size, cast(void*)data);
        checkError();
    }

    void* mapBuffer(BufferType type, BufferAccess access) {
        auto res = glMapBuffer(type, access);
        checkError();
        return res;
    }

    void unmapBuffer(BufferType type) {
        glUnmapBuffer(type);
        checkError();
    }

    void genFramebuffers(uint num, FramebufferID* ptr) {
        glGenFramebuffers(num, ptr);
        checkError();
    }

    void deleteFramebuffers(uint num, FramebufferID* ptr) {
        glDeleteFramebuffers(num, ptr);
        checkError();
    }

    void bindFramebuffer(FramebufferBindType type, FramebufferID id) {
        glBindFramebuffer(type, id);
        checkError();
    }

    void framebufferRenderbuffer(FramebufferBindType bindType, FramebufferAttachType attachType, RenderbufferID renderbufferID) {
        glFramebufferRenderbuffer(bindType, attachType, RenderbufferBindType.Both, renderbufferID);
    }

    void blitFramebuffer(uint srcX0, uint srcY0, uint srcX1, uint srcY1, uint dstX0, uint dstY0, uint dstX1, uint dstY1, TextureFilter filter, BufferBit[] bit...) {
        import std.algorithm : reduce;
        glBlitFramebuffer(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, bit.reduce!((a,b)=>a|b), filter);
        checkError();
    }

    void genRenderbuffers(uint num, RenderbufferID* ptr) {
        glGenRenderbuffers(num, ptr);
        checkError();
    }

    void deleteRenderbuffers(uint num, RenderbufferID* ptr) {
        glDeleteRenderbuffers(num, ptr);
        checkError();
    }

    void bindRenderbuffer(RenderbufferID id) {
        glBindRenderbuffer(RenderbufferBindType.Both, id);
        checkError();
    }

    void renderbufferStorage(uint width, uint height, ImageInternalFormat format) {
        glRenderbufferStorage(RenderbufferBindType.Both, format, width, height);
        checkError();
    }

    void genTextures(uint num, TextureID *ptr) {
        glGenTextures(num, ptr);
        checkError();
    }

    void deleteTextures(uint num, TextureID *ptr) {
        glDeleteTextures(num, ptr);
        checkError();
    }

    void bindTexture(TextureTarget target, TextureID id) {
        glBindTexture(target, id);
        checkError();
    }

    void activeTexture(uint unit) {
        glActiveTexture(GL_TEXTURE0 + unit);
        checkError();
    }

    void texImage2D(Type)(TextureTarget target, uint mipmapLevel, ImageInternalFormat iformat, uint width, uint height, uint border, ImageFormat format, Type *data) {
        glTexImage2D(target, mipmapLevel, iformat, width, height, border, format, GlUtils.getTypeEnum!Type, data);
        checkError();
    }

    void texSubImage2D(Type)(TextureTarget target, uint mipmapLevel, uint offsetX, uint offsetY, uint width, uint height, ImageFormat format, Type *data) {
        glTexSubImage2D(target, mipmapLevel, offsetX, offsetY, width, height, format, GlUtils.getTypeEnum!Type, data);
        checkError();
    }

    void bindImageTexture(uint unit, TextureID id, uint level, bool layered, uint layer, BufferAccess access, ImageInternalFormat format)
        in(unit < GL_MAX_IMAGE_UNITS)
    do {
        glBindImageTexture(unit, id, level, layered, layer, access, format);
        checkError();
    }

    void framebufferTexture2D(FramebufferBindType bindType, FramebufferAttachType attachType, TextureTarget target, TextureID id, uint level) {
        glFramebufferTexture2D(bindType, attachType, target, id, level);
        checkError();
    }

    void getTexImage(Type)(TextureTarget target, uint level, ImageFormat format, Type* ptr) {
        glGetTexImage(target, level, format, GlUtils.getTypeEnum!(Type), ptr);
        checkError();
    }

    void genVertexArrays(uint num, VertexArrayID *ptr) {
        glGenVertexArrays(num, ptr);
        checkError();
    }

    void deleteVertexArray(uint num, VertexArrayID *ptr) {
        glDeleteVertexArrays(num, ptr);
        checkError();
    }

    void bindVertexArray(VertexArrayID id) {
        glBindVertexArray(id);
        checkError();
    }

    void drawArrays(Prim prim, uint offset, uint count) {
        glDrawArrays(prim, offset, count);
        checkError();
    }

    void drawElements(IndexType)(Prim prim, uint length, IndexType* indices) 
        if (is(IndexType == ubyte) || is(IndexType == ushort) || is(IndexType == uint))
    {
        glDrawElements(prim, length, GlUtils.getTypeEnum!(IndexType), cast(void*)indices);
        GlFunction.checkError();
    }

    void setViewport(uint x, uint y, uint w, uint h) {
        glViewport(x,y,w,h);
        checkError();
    }

    void scissor(uint x, uint y, uint width, uint height) {
        enable(Capability.ScissorTest);
        glScissor(x, y, width, height);
        checkError();
    }

    ProgramID createProgram() {
        auto id = glCreateProgram();
        checkError();
        return id;
    }

    void deleteProgram(ProgramID id) {
        glDeleteProgram(id);
        checkError();
    }

    void useProgram(ProgramID id) {
        glUseProgram(id);
        checkError();
    }

    void linkProgram(ProgramID id) {
        glLinkProgram(id);
        checkError();
    }

    void getProgramInfoLog(ProgramID id, int maxLength, int *length, char *infoLog) {
        glGetProgramInfoLog(id, maxLength, length, infoLog);
        checkError();
    }

    void attachShader(ProgramID programID, ShaderID shaderID) {
        glAttachShader(programID, shaderID);
        checkError();
    }

    AttribLoc getAttribLocation(ProgramID programID, string name) {
        import std.string : toStringz;
        auto loc = glGetAttribLocation(programID, name.toStringz);
        checkError();
        return loc;
    }

    UniformLoc getUniformLocation(ProgramID programID, string name) {
        import std.string : toStringz;
        auto loc = glGetUniformLocation(programID, name.toStringz);
        checkError();
        return loc;
    }

    ShaderID createShader(ShaderType type) {
        auto id = glCreateShader(type);
        checkError();
        return id;
    }

    void deleteShader(ShaderID id) {
        glDeleteShader(id);
        checkError();
    }

    void shaderSource(ShaderID id, uint num, char** sourceList, int* lengthList) {
        glShaderSource(id, num, sourceList, lengthList);
        checkError();
    }

    void compileShader(ShaderID id) {
        glCompileShader(id);
        checkError();
    }

    void getShaderInfoLog(ShaderID id, int maxLength, int *length, char *infoLog) {
        glGetShaderInfoLog(id, maxLength, length, infoLog);
        checkError();
    }

    void enableVertexAttribArray(AttribLoc loc) {
        glEnableVertexAttribArray(loc);
        checkError();
    }

    void vertexAttribPointer(Type)(AttribLoc loc, uint size, bool normalized, uint stride, Type* ptr) {
        glVertexAttribPointer(loc, size, GlUtils.getTypeEnum!(Type), normalized, stride, cast(void*)ptr);
        checkError();
    }

    void dispatchCompute(uint groupNumX, uint groupNumY, uint groupNumZ) {
        glDispatchCompute(groupNumX, groupNumY, groupNumZ);
        checkError();
    }

    void uniformBlockBinding(ProgramID programID, uint loc, uint uniformBlockPoint) {
        glUniformBlockBinding(programID, loc, uniformBlockPoint);
        checkError();
    }

    void bindBufferBase(BufferType type, uint blockPoint, BufferID id) {
        glBindBufferBase(type, blockPoint, id);
        checkError();
    }

    UniformLoc getUniformBlockIndex(ProgramID programID, string name) {
        import std.string : toStringz;
        int loc = glGetUniformBlockIndex(programID, name.toStringz);
        checkError();
        return loc;
    }

    auto get(T, size_t N)(ParamName param) {
        T[N] data;
        getFunction!T(param, data.ptr);
        checkError();
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
        checkError();
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
        checkError();
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
        checkError();
    }

    private template getTexParamFunction(T) {
        alias getTexParamFunction = glTexParameteri;
    }

    void uniform(T, size_t N)(UniformLoc loc, uint num, T* ptr) 
        if (1 <= N && N <= 4)
    {
        import std.format;
        mixin(format!"glUniform%d%sv"(N, getUniformTypeCharacter!(T)))(loc, num, ptr);
        checkError();
    }

    void uniformMatrix(T, size_t N)(UniformLoc loc, uint num, T* ptr) 
        if (1 <= N && N <= 4)
    {
        import std.format;
        mixin(format!"glUniformMatrix%d%sv"(N, getUniformTypeCharacter!(T)))(loc, num, true, ptr);
        checkError();
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

    private void checkError(string ext = "", string fileName=__FILE__) {
        debug {
            import sbylib.wrapper.glfw.GLFW;
            import std.conv : to;
            if (GLFW.hasTerminated) return;
            auto errorCode = glGetError().to!GlErrorType;
            if (errorCode == GlErrorType.NoError) return;
            if (errorCode == GlErrorType.InvalidFramebufferOperation) {
                auto status = glCheckFramebufferStatus(GL_FRAMEBUFFER).to!FramebufferStatus;
                assert(false, errorCode.to!string ~ " : " ~ status.to!string ~ "\n" ~ ext ~ " at " ~ fileName);
            } else {
                assert(false, errorCode.to!string ~ "\n" ~ ext ~ " at " ~ fileName);
            }
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
        if (mode.canFind(ClearMode.Color)) GlUtils.colorWrite(true);  //これしないとColorをClearできない
        if (mode.canFind(ClearMode.Depth)) GlUtils.depthWrite(true); //これしないとDepthをClearできない
        if (mode.canFind(ClearMode.Stencil)) GlUtils.stencilWrite(true); //これしないとStencilをClearできない

        GlFunction.clear(mode);
    }

    void clearColor(vec4 color) {
        GlFunction.clearColor(color.r, color.g, color.b, color.a);
    }

    void colorWrite(bool write) {
        GlFunction.colorMask(write, write, write, write);
    }

    alias depthWrite = GlFunction.depthMask;

    void stencilWrite(bool write) {
        GlFunction.stencilMask(write ? uint.max : 0);
    }

    void depthTest(bool depthTest) {
        if (depthTest) {
            GlFunction.enable(Capability.DepthTest);
        } else {
            GlFunction.disable(Capability.DepthTest);
        }
    }

    void faceSetting(PolygonMode polygon, FaceMode face = FaceMode.FrontBack) {
        if (polygon == PolygonMode.None) {
            assert(face == FaceMode.FrontBack);
            GlFunction.enable(Capability.CullFace);
            GlFunction.cullFace(FaceMode.FrontBack);
        } else {
            final switch (face) {
            case FaceMode.FrontBack:
                //glDisable(Capability.CullFace);
                GlFunction.polygonMode(FaceMode.FrontBack, polygon);
                break;
            case FaceMode.Front:
                GlFunction.enable(Capability.CullFace);
                GlFunction.cullFace(FaceMode.Back);
                GlFunction.polygonMode(FaceMode.FrontBack, polygon);
                break;
            case FaceMode.Back:
                GlFunction.enable(Capability.CullFace);
                GlFunction.cullFace(FaceMode.Front);
                GlFunction.polygonMode(FaceMode.FrontBack, polygon);
                break;
            }
        }
    }


    void stencil(TestFunc test, int reffer, uint mask, StencilWrite sfail, StencilWrite dpfail, StencilWrite pass) {
        GlFunction.enable(Capability.StencilTest);
        GlFunction.stencilFunc(test, reffer, mask);
        GlFunction.stencilOp(sfail, dpfail, pass);
    }

    int getBitPerPixel(ImageInternalFormat iformat) {
        final switch (iformat) {
            case ImageInternalFormat.R:
                return 32;
            case ImageInternalFormat.RG:
                return 32;
            case ImageInternalFormat.RGB:
                return 32;
            case ImageInternalFormat.RGB8:
                return 24;
            case ImageInternalFormat.RGBA:
                return 32;
            case ImageInternalFormat.RGBA16F:
                return 16;
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
        return GlFunction.get!(float, 2)(ParamName.AliasedLineWidthRange);
    }

    float[2] getSmoothLineWidthRange() {
        return GlFunction.get!(float, 2)(ParamName.SmoothLineWidthRange);
    }

    BufferID genBuffer() {
        uint result;
        GlFunction.genBuffers(1, &result);
        return result;
    }

    void deleteBuffer(BufferID id) {
        GlFunction.deleteBuffers(1, &id);
    }

    FramebufferID genFramebuffer() {
        uint result;
        GlFunction.genFramebuffers(1, &result);
        return result;
    }

    void deleteFramebuffer(FramebufferID id) {
        GlFunction.deleteFramebuffers(1, &id);
    }

    RenderbufferID genRenderbuffer() {
        uint result;
        GlFunction.genRenderbuffers(1, &result);
        return result;
    }

    void deleteRenderbuffer(RenderbufferID id) {
        GlFunction.deleteRenderbuffers(1, &id);
    }

    TextureID genTexture() {
        uint result;
        GlFunction.genTextures(1, &result);
        return result;
    }

    void deleteTexture(TextureID id) {
        GlFunction.deleteTextures(1, &id);
    }

    VertexArrayID genVertexArray() {
        uint result;
        GlFunction.genVertexArrays(1, &result);
        return result;
    }

    void deleteVertexArray(VertexArrayID id) {
        GlFunction.deleteVertexArray(1, &id);
    }

    void shaderSource(ShaderID id, string source) {
        import std.string : toStringz;
        auto str = source.toStringz;
        GlFunction.shaderSource(id, 1, cast(char**)&str, null);
    }

    void uniform(T)(UniformLoc loc, T data) {
        import std.traits : Unqual;
        static if (is(Unqual!T == bool)) {
            int d = data;
        } else {
            auto d = data;
        }
        GlFunction.uniform!(typeof(d), 1)(loc, 1, &d);
    }

    void uniform(T, size_t N)(UniformLoc loc, T[N] data) {
        GlFunction.uniform!(T, N)(loc, 1, data.ptr);
    }

    void uniformMatrix(T, size_t N)(UniformLoc loc, T[N*N] data) {
        GlFunction.uniformMatrix!(T, N)(loc, 1, data.ptr);
    }
}
