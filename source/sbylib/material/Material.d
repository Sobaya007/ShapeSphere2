module sbylib.material.Material;

import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.Program;
import sbylib.wrapper.gl.Attribute;
import sbylib.wrapper.gl.BufferObject;
import sbylib.wrapper.gl.VertexArray;
import sbylib.utils.Lazy;
import sbylib.material.glsl.GlslUtils;
import sbylib.material.glsl.UniformDemand;
import sbylib.material.RenderConfig;
import std.algorithm;
import std.typecons;
import std.array;

alias umat4w = Lazy!(umat4);

class Material {

    const Program shader;
    RenderConfig config;

    this(const Program shader) {
        this.shader = shader;
        this.config = new RenderConfig();
    }

    final void set(Lazy!(Uniform)[string] uniforms) {
        this.config.set();
        this.shader.use();
        uint uniformBlockPoint = 0;
        uint textureUnit = 0;
        import std.stdio;
        foreach (uni; uniforms) {
            //writeln(getUniform());
            uni.apply(this.shader, uniformBlockPoint, textureUnit);
        }
    }

    abstract UniformDemand[] getDemands();
    abstract Lazy!Uniform [] getUniforms();
}

class MaterialTemp(UniformKeeper) : Material {

    import sbylib.wrapper.gl.Shader;
    import sbylib.wrapper.gl.Program;
    import sbylib.wrapper.gl.Constants;
    import sbylib.material.glsl.GlslUtils;
    import sbylib.material.glsl.Ast;
    import std.file;

    alias Keeper = UniformKeeper;

    private UniformDemand[] demands;
    private Shader vertexShader, fragmentShader;
    UniformKeeper keeper;

    this() {
        this((obj){});
    }

    this(void delegate(UniformKeeper) constructor) {
        if (!demands) {
            auto fragAST = UniformKeeper.generateFragmentAST();
            auto vertAST = GlslUtils.generateVertexAST(fragAST);
            import std.stdio;
            //writeln(fragAST.getCode);
            demands = GlslUtils.requiredUniformDemands([vertAST, fragAST]);
            vertexShader = new Shader(vertAST.getCode(), ShaderType.Vertex);
            fragmentShader = new Shader(fragAST.getCode(), ShaderType.Fragment);
        }
        const program = new Program([vertexShader, fragmentShader]);
        super(program);
        this.keeper = new UniformKeeper(constructor);
    }

    ref auto opDispatch(string s)() {
        return mixin("this.keeper." ~ s );
    }

    override UniformDemand[] getDemands() {
        return this.demands;
    }

    override Lazy!Uniform [] getUniforms() {
        return this.keeper.getUniforms();
    }
}
