module sbylib.wrapper.gl.Program;

import sbylib.wrapper.gl.Attribute;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Shader;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.VertexBuffer;
import sbylib.wrapper.gl.Uniform;
import derelict.opengl;
import std.file, std.stdio, std.string, std.conv, std.range, std.algorithm;
import std.ascii;

class Program {

    package immutable uint id;
    private bool alive = true;

    /* For Uniform */
    private uint uniformBlockPoint = 0;
    private uint textureUnit = 0;
    private debug bool inUseOfUniform;

    this(const Shader[] shaders) in {
        debug {
            import std.algorithm : canFind;

            bool hasVertex = shaders.canFind!(shader => shader.getType() == ShaderType.Vertex);
            bool hasFragment = shaders.canFind!(shader => shader.getType() == ShaderType.Fragment);
            bool hasCompute = shaders.canFind!(shader => shader.getType() == ShaderType.Compute);
            assert(hasVertex && hasFragment || hasCompute);
        }
    } out {
        GlFunction.checkError();
    } body {
        this.id = glCreateProgram();
        foreach (shader; shaders) {
            this.attachShader(shader);
        }
        this.linkProgram;
        assert(this.getLinkStatus, getLogString());
    }

    ~this() {
        // Material Exampleにて爆発。
        // なんか謎のMaterial解放が原因っぽい。
        // とりあえずめんどいので放置。
        //assert(!alive);
        import std.stdio;
        if (alive) writeln("Invalid Destruction For Program");
    }

    void destroy() in {
        assert(alive);
    } out {
        GlFunction.checkError();
    } do {
        alive = false;
        glDeleteProgram(id);
    }

    void beginUniform() in {
        debug assert(!inUseOfUniform);
    } out {
        debug assert(inUseOfUniform);
    } do {
        this.use();
        this.uniformBlockPoint = 0;
        this.textureUnit = 0;
        debug this.inUseOfUniform = true;
    }

    void applyUniform(const Uniform uniform) in {
        debug assert(inUseOfUniform);
    } do {
        uniform.apply(this, uniformBlockPoint, textureUnit);
    }

    void applyUniform(UniformRange)(UniformRange uniforms) {
        foreach (uni; uniforms) {
            applyUniform(uni);
        }
    }

    void endUniform() in {
        debug assert(inUseOfUniform);
    } out {
        debug assert(!inUseOfUniform);
    } do {
        debug inUseOfUniform = false;
    }

    void applyAllUniform(UniformRange)(UniformRange uniforms) {
        this.beginUniform();
        this.applyUniform(uniforms);
        this.endUniform();
    }

    inout {

        void use() in {
            assert(alive);
        } out {
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

        bool hasAttribute(string name) in {
            assert(alive);
        } out {
            GlFunction.checkError();
        } body {
            int vLoc = glGetAttribLocation(this.id, name.toStringz);
            return vLoc != -1;
        }

        uint getAttribLocation(string name) in {
            assert(alive);
        } out {
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

