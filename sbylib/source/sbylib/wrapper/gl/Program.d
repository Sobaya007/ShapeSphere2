module sbylib.wrapper.gl.Program;

import sbylib.wrapper.gl.ObjectGL;

class Program : ObjectGL {

    import sbylib.wrapper.gl.Attribute;
    import sbylib.wrapper.gl.Constants;
    import sbylib.wrapper.gl.Functions;
    import sbylib.wrapper.gl.Shader;
    import sbylib.wrapper.gl.Uniform;
    import sbylib.wrapper.gl.VertexBuffer;

    /* For Uniform */
    private uint uniformBlockPoint = 0;
    private uint textureUnit = 0;
    private debug bool inUseOfUniform;

    this(const Shader[] shaders)
    in {
        debug {
            import std.algorithm : canFind;

            bool hasVertex = shaders.canFind!(shader => shader.getType() == ShaderType.Vertex);
            bool hasFragment = shaders.canFind!(shader => shader.getType() == ShaderType.Fragment);
            bool hasCompute = shaders.canFind!(shader => shader.getType() == ShaderType.Compute);
            assert(hasVertex && hasFragment || hasCompute);
        }
    } 
    do {
        super(GlFunction().createProgram(),
                &GlFunction().deleteProgram);
        foreach (shader; shaders) {
            this.attachShader(shader);
        }
        this.linkProgram();
        assert(this.getLinkStatus, getLogString());
    }

    void beginUniform()
    in {
        debug assert(!inUseOfUniform);
    } 
    out {
        debug assert(inUseOfUniform);
    } 
    do {
        this.use();
        this.uniformBlockPoint = 0;
        this.textureUnit = 0;
        debug this.inUseOfUniform = true;
    }

    void applyUniform(const Uniform uniform)
    in {
        debug assert(inUseOfUniform);
    }
    do {
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

        void use() {
            GlFunction().useProgram(id);
        }

        void enableAttribute(Attribute attr) {
            immutable loc = this.getAttribLocation(attr.name);
            GlFunction().enableVertexAttribArray(loc);
        }

        void attachAttribute(Attribute attr, VertexBuffer buffer) {
            immutable loc = this.getAttribLocation(attr.name);
            buffer.asAttribute(attr.dim, loc);
        }

        bool hasAttribute(string name) {
            int vLoc = GlFunction().getAttribLocation(this.id, name);
            return vLoc != -1;
        }

        uint getAttribLocation(string name) {
            int vLoc = GlFunction().getAttribLocation(this.id, name);
            assert(vLoc != -1);
            return vLoc;
        }

        private void attachShader(const Shader shader) {
            GlFunction().attachShader(this.id, shader.id);
        }

        private void linkProgram() {
            GlFunction().linkProgram(this.id);
        }

        private int getInfo(ProgramParamName name) {
            return GlFunction().getProgram!(int, 1)(this.id, name)[0];
        }

        private bool getLinkStatus() {
            return getInfo(ProgramParamName.LinkStatus) > 0;
        }

        private int getLogLength() {
            return getInfo(ProgramParamName.InfoLogLength);
        }

        private string getInfoLog() {
            auto logLength = this.getLogLength;
            char[] log = new char[logLength];
            GlFunction().getProgramInfoLog(this.id, logLength, &logLength, &log[0]);

            import std.conv;
            return log.to!string;
        }

        private string getLogString() {
            return "GLSL Link Error\n" ~ getInfoLog;
        }
    }
}

