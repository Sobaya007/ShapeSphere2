module sbylib.wrapper.gl.Program;

import sbylib.wrapper.gl;
import derelict.opengl;
import std.file, std.stdio, std.string, std.conv, std.range, std.algorithm;
import std.ascii;

class Program {

    package immutable uint id;

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

        private uint getAttribLocation(string name) {
            int vLoc = glGetAttribLocation(this.id, name.toStringz);
            //if (vLoc == -1) writeln(name ~ " is not found or used.");
            return vLoc;
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

