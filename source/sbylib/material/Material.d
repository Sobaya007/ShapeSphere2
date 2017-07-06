module sbylib.material.Material;

import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.Program;
import sbylib.wrapper.gl.Attribute;
import sbylib.wrapper.gl.BufferObject;
import sbylib.wrapper.gl.VertexArray;
import sbylib.utils.Watcher;
import sbylib.material.glsl.GlslUtils;
import sbylib.material.glsl.UniformDemand;
import sbylib.material.RenderConfig;
import std.algorithm;
import std.typecons;
import std.array;

alias umat4w = Watcher!(umat4);

class Material {

    const Program shader;
    private Uniform delegate()[string] getUniforms;
    RenderConfig config;

    this(const Program shader) {
        this.shader = shader;
        this.config = new RenderConfig();
    }

    final void setUniform(Uniform delegate() getUniform) {
        auto name = getUniform().getName();
        this.getUniforms[name] = getUniform;
    }

    final void setUniform(T)(Watcher!(T) watcher) {
        auto name = watcher.get().getName();
        this.getUniforms[name] = () => watcher.get();
    }

    final void set() {
        this.config.set();
        this.shader.use();
        uint uniformBlockPoint = 0;
        uint textureUnit = 0;
        import std.stdio;
        foreach (getUniform; getUniforms) {
            //writeln(getUniform());
            getUniform().apply(this.shader, uniformBlockPoint, textureUnit);
        }
    }

//    ref auto opDispatch(string s)() in {
//        assert(s in getUniforms);
//    } body {
//        return getUniform[s];
//    }

    abstract UniformDemand[] getDemands();
}

class MaterialTemp(UniformKeeper) : Material {

    import sbylib.wrapper.gl.Shader;
    import sbylib.wrapper.gl.Program;
    import sbylib.wrapper.gl.Constants;
    import sbylib.material.glsl.GlslUtils;
    import sbylib.material.glsl.Ast;
    import sbylib.setting;
    import std.file;

    alias Keeper = UniformKeeper;

    private UniformDemand[] demands;
    private Shader vertexShader, fragmentShader;
    UniformKeeper keeper;

    this() {
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

        this.keeper = new UniformKeeper(this);
    }

    ref auto opDispatch(string s)() {
        return mixin("this.keeper." ~ s );
    }

    override UniformDemand[] getDemands() {
        return this.demands;
    }
}
