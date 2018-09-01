module sbylib.wrapper.gl.Shader;

import sbylib.wrapper.gl.ObjectGL;

class Shader : ObjectGL {

    import sbylib.wrapper.gl.Constants;
    import sbylib.wrapper.gl.Functions;

    private debug string sourceCode;
    private debug ShaderType type;

    this(string sourceCode, ShaderType type) {
        debug {
            this.sourceCode = sourceCode;
            this.type = type;
        }
        super(GlFunction().createShader(type),
                (ShaderID id) { GlFunction().deleteShader(id); });
        GlUtils.shaderSource(this.id, sourceCode);
        GlFunction().compileShader(this.id);
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
            return getInfo(ShaderParamName.CompileStatus) == true;
        }

        int getInfo(ShaderParamName name) {
            return GlFunction().getShader!(int, 1)(this.id, name)[0];
        }

        string getInfoLog() {
            auto logLength = getLogLength();
            char[] log = new char[logLength];
            GlFunction().getShaderInfoLog(this.id, logLength, &logLength, &log[0]);

            import std.conv : to;
            return log.to!string;
        }

        private string getLogString(string sourceCode) {
            import std.string : splitLines, split;
            import std.algorithm : all, sort, canFind;
            import std.range : assumeSorted;
            import std.array :array;
            import std.ascii : isDigit;
            import std.conv : to;
            import std.stdio : writeln;

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
                writeln(r);
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

    debug string getSourceCode() const {
        return this.sourceCode;
    }

    debug ShaderType getType() const {
        return this.type;
    }
}
