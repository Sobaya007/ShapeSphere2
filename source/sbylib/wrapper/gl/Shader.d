module sbylib.wrapper.gl.Shader;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;
import derelict.opengl;
import std.file, std.stdio, std.string, std.conv, std.range, std.algorithm;
import std.ascii;

class Shader {
    package immutable uint id;

    this(string sourceCode, ShaderType type) out {
        GlFunction.checkError();
    } body {
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

        int getInfo(ShaderParamName name) out {
            GlFunction.checkError();
        } body {
            int res;
            glGetShaderiv(this.id, name, &res);
            return res;
        }

        string getInfoLog() out {
            GlFunction.checkError();
        } body {
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
            lineNum = lineNum.sort().array;
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
