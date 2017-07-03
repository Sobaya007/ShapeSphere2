module sbylib.wrapper.gl.Program;

import sbylib.wrapper.gl.Attribute;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Shader;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.VertexBuffer;
import derelict.opengl;
import std.file, std.stdio, std.string, std.conv, std.range, std.algorithm;
import std.ascii;

class Program {

    package immutable uint id;

    this(const Shader[] shaders) out {
        GlFunction.checkError();
    } body {
        this.id = glCreateProgram();
        foreach (shader; shaders) {
            this.attachShader(shader);
        }
        this.linkProgram;
        assert(this.getLinkStatus, getLogString());
    }

    ~this() out {
        GlFunction.checkError();
    } body {
        glDeleteProgram(id);
    }

    inout {

        void use() out {
            GlFunction.checkError();
        } body {
            glUseProgram(id);
        }

        void enableAttribute(Attribute attr) out {
            GlFunction.checkError();
        } body {
            immutable loc = this.getAttribLocation(attr.name);
            glEnableVertexAttribArray(loc);
        }

        void attachAttribute(Attribute attr, VertexBuffer buffer) out {
            GlFunction.checkError();
        } body {
            immutable loc = this.getAttribLocation(attr.name);
            buffer.asAttribute(attr.dim, loc);
        }

        bool hasAttribute(string name) out {
            GlFunction.checkError();
        } body {
            int vLoc = glGetAttribLocation(this.id, name.toStringz);
            return vLoc != -1;
        }

        uint getAttribLocation(string name) out {
            GlFunction.checkError();
        } body {
            int vLoc = glGetAttribLocation(this.id, name.toStringz);
            assert(vLoc != -1);
            return vLoc;
        }

        private void attachShader(const Shader shader) out {
            GlFunction.checkError();
        } body {
            glAttachShader(this.id, shader.id);
        }

        private void linkProgram() out {
            GlFunction.checkError();
        } body {
            glLinkProgram(id);
        }

        private int getInfo(ProgramParamName name) out {
            GlFunction.checkError();
        } body {
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

        private string getInfoLog() out {
            GlFunction.checkError();
        } body {
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

