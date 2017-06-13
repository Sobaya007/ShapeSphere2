module sbylib.wrapper.gl.Shader;

import sbylib.wrapper.gl;
import derelict.opengl;
import std.file, std.stdio, std.string, std.conv, std.range, std.algorithm;
import std.ascii;

class ShaderProgram {

    private immutable uint id;

    this(const Shader[] shaders) {
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

    inout {

        void use() {
            glUseProgram(id);
        }

        void enableAttribute(Attribute attr) {
            immutable loc = this.getAttribLocation(attr.name);
            glEnableVertexAttribArray(loc);
        }

        void attachAttribute(Attribute attr, VertexBuffer buffer) {
            immutable loc = this.getAttribLocation(attr.name);
            buffer.asAttribute(attr.dim, loc);
        }

        void attachUniform(inout Uniform uniform) {
            immutable loc = this.getUniformLocation(uniform.getName());
            uniform.apply(loc);
        }

        private uint getAttribLocation(string name) {
            int vLoc = glGetAttribLocation(this.id, name.toStringz);
            //if (vLoc == -1) writeln(name ~ " is not found or used.");
            return vLoc;
        }

        private uint getUniformLocation(string name) {
            int uLoc = glGetUniformLocation(this.id, name.toStringz);
            //if (uLoc == -1) writeln(name ~ " is not found or used."); 
            return uLoc;
        }

        private void attachShader(const Shader shader) {
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
}

class Shader {
    private immutable uint id;

    this(string sourceCode, ShaderType type) {
        this.id = glCreateShader(type);
        auto str = sourceCode.toStringz;
        glShaderSource(this.id, 1, &str, null);
        glCompileShader(this.id);
        assert(this.compileSuccess(), getLogString(sourceCode));
    }

    inout {

        ShaderType getShaderType() {
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

        int getLogLength() {
            return this.getInfo(ShaderParamName.InfoLogLength);
        }

        bool compileSuccess() {
            return getInfo(ShaderParamName.CompileStatus) == GL_TRUE;
        }

        int getInfo(ShaderParamName name) {
            int res;
            glGetShaderiv(this.id, name, &res);
            return res;
        }

        string getInfoLog() {
            auto logLength = getLogLength();
            char[] log = new char[logLength];
            glGetShaderInfoLog(this.id, logLength, &logLength, &log[0]);
            return log.to!string.chomp;
        }

        private string getLogString(string sourceCode) {
            auto log = getInfoLog;
            auto lines = log.splitLines;
            int[] lineNum;
            foreach (string line; lines) {
                auto strs = split(line, ":");
                if (strs.length > 0 && strs[0] == "ERROR") {
                    auto c = strs[2];
                    if (c.all!(a => a.isDigit)) {
                        lineNum ~= to!int(c)-1;
                    }
                }
            }
            auto r = assumeSorted(lineNum);
            string result = "\nGLSL Compile Error\n";
            result ~= "==========================================\n";
            auto strs = sourceCode.splitLines;
            foreach (int i, str; strs) {
                if (r.canFind(i)) {
                    result ~= "▶";
                } else {
                    result ~= "　";
                }
                result ~= str;
                result ~= "\n";
            }
            result ~= "==========================================\n";
            result ~= log;
            result ~= "==========================================\n";
            return result;
        }
    }
}
