module sbylib.gl.ShaderProgram;

import sbylib.gl;
import derelict.opengl;
import std.file, std.stdio, std.string, std.conv, std.range, std.algorithm;

class ShaderProgram {

    private immutable uint id;

    this(Shader[] shaders) {
        this.id = glCreateProgram();
        foreach (shader; shaders) {
            this.attachShader(shader);
        }
        this.linkProgram;
        assert(this.getLinkStatus, getLogString());
    }

    ~this() {
        glDeleteProgram(id);
    }

    void use() {
        glUseProgram(id);
    }

    void attribute(int dim, string name) {
        glVertexAttribPointer(getAttribLocation(name), dim, GL_FLOAT, GL_FALSE, cast(int)(dim * float.sizeof), null);
    }

    void enableAttribute(string name) {
        glEnableVertexAttribArray(getAttribLocation(name));
    }

    uint getAttribLocation(string name) {
        int vLoc = glGetAttribLocation(this.id, name.toStringz);
        assert(vLoc != -1, name ~ " is not found or used."); 
        return vLoc;
    }

    uint getUniformLocation(string name) {
        int uLoc = glGetUniformLocation(this.id, name.toStringz);
        assert(uLoc != -1, name ~ " is not found or used."); 
        return uLoc;
    }

    private void attachShader(Shader shader) {
        glAttachShader(this.id, shader.id);
    }

    private void linkProgram() {
        glLinkProgram(id);
    }

    private int getInfo(ProgramParamName name) {
        int res;
        glGetProgramiv(this.id, name, &res);
        return res;
    }

    private bool getLinkStatus() {
        return getInfo(ProgramParamName.LinkStatus) == GL_TRUE;
    }

    private int getLogLength() {
        return getInfo(ProgramParamName.InfoLogLength);
    }

    private string getInfoLog() {
        immutable logLength = this.getLogLength;
        char[] log = new char[logLength];
        int a;
        glGetProgramInfoLog(this.id, logLength, &a, &log[0]);
        return log.to!string;
    }

    private string getLogString() {
        return "GLSL Link Error\n" ~ getInfoLog;
    }
}

class Shader {
    immutable uint id;

    this(string sourceCode, ShaderType type) {
        this.id = glCreateShader(type);
        auto str = sourceCode.toStringz;
        glShaderSource(this.id, 1, &str, null);
        glCompileShader(this.id);
        assert(!this.getCompileStatus, getLogString(sourceCode));
    }

    private ShaderType getShaderType() {
        int res = getInfo(ShaderParamName.ShaderType);
        switch(res) {
        case ShaderType.Vertex:
            return ShaderType.Vertex;
        case ShaderType.Fragment:
            return ShaderType.Fragment;
        case ShaderType.Geometry:
            return ShaderType.Geometry;
        default:
            assert(false);
        }
    }

    private int getLogLength() {
        return getInfo(ShaderParamName.InfoLogLength);
    }

    private bool getCompileStatus() {
        return getInfo(ShaderParamName.CompileStatus) == GL_TRUE;
    }

    private int getInfo(ShaderParamName name) {
        int res;
        glGetProgramiv(this.id, name, &res);
        return res;
    }

    private string getInfoLog() {
        immutable logLength = this.getLogLength;
        char[] log = new char[logLength];
        int a;
        glGetShaderInfoLog(this.id, logLength, &a, &log[0]);
        return log.to!string;
    }

    private string getLogString(string sourceCode) {
        auto lines = getInfoLog.splitLines;
        int[] lineNum;
        foreach (string line; lines) {
            auto strs = split(line, ":");
            if (strs.length > 0 && strs[0] == "ERROR") {
                auto c = strs[1].split[0];
                lineNum ~= to!int(c)-1;
            }
        }
        auto r = assumeSorted(lineNum);
        string result = "GLSL Compile Error\n";
        auto strs = sourceCode.splitLines;
        foreach (int i, str; strs) {
            if (r.canFind(i)) {
                result ~= "▶";
                result ~= str;
            } else {
                result ~= str;
            }
            result ~= "\n";
        }
        return result;
    }
}
