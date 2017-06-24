module sbylib.material.MaterialUtils;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Shader;
import sbylib.wrapper.gl.Program;
import sbylib.setting;
import sbylib.material.glsl.GlslUtils;
import sbylib.material.glsl.Ast;
import std.file;

class MaterialUtils {

    private this(){}

    static {
        const(Shader) createShaderFromPath(string path, ShaderType type) {
            path = ROOT_PATH ~ path;
            auto source = readText(path);
            return new Shader(source, type);
        }

        const(Program) createProgramFromPath(string vertPath, string fragPath, string geomPath = null) {
            auto vert = createShaderFromPath(vertPath, ShaderType.Vertex);
            auto frag = createShaderFromPath(fragPath, ShaderType.Fragment);
            auto shaders = [vert, frag];
            if (geomPath) {
                auto geom = createShaderFromPath(geomPath, ShaderType.Geometry);
                shaders ~= geom;
            }
            return new Program(shaders);
        }
    }

    mixin template declare(string file = __FILE__) {
        import std.string;
        import std.file;
        import sbylib.material.glsl.Ast;
        import sbylib.material.glsl.GlslUtils;
        enum FRAG_ROOT = file.replace(".d", ".frag");

        static Ast[2] generateASTs() {
            auto fragSource = readText(FRAG_ROOT);
            auto fragAST = GlslUtils.generateFragmentAST(new Ast(fragSource));
            auto vertAST = GlslUtils.generateVertexAST(fragAST);
            return [vertAST, fragAST];
        }

        override Uniform[] getUniforms() {
            import std.traits;
            Uniform[] result;
            foreach (i, type; FieldTypeTuple!(typeof(this))) {
                if (isAssignable!(Uniform, type)) {
                    result ~= mixin("this." ~ FieldNameTuple!(typeof(this))[i]);
                }
            }
            return result;
        }

        this(Material mat) {
            this(mat, s => s);
        }

        this(Material mat, string delegate(string) replace) {
            static if(__traits(hasMember, typeof(this), "constructor")) {
                constructor();
            }
            foreach (uni; this.getUniforms) {
                uni.setName(replace(uni.getName()));
                mat.setUniform(() => uni);
            }
        }

    }

    mixin template declareMix(alias A, alias B, string file = __FILE__) {

        import std.string;
        import std.file;
        import sbylib.material.glsl.Ast;
        import sbylib.material.glsl.GlslUtils;
        enum FRAG_ROOT = file.replace(".d", ".frag");

        static Ast[2] generateASTs() {
            Ast[] fragASTs;
            auto ast1 = GlslUtils.generateFragmentAST(new Ast(readText(A.Keeper.FRAG_ROOT)));
            ast1.name = MaterialName1;
            fragASTs ~= ast1;
            auto ast2 = GlslUtils.generateFragmentAST(new Ast(readText(B.Keeper.FRAG_ROOT)));
            ast2.name = MaterialName2;
            fragASTs ~= ast2;
            auto mainAst = GlslUtils.generateFragmentAST(new Ast(readText(FRAG_ROOT)));
            mainAst.name = "main";
            auto fragAST = GlslUtils.mergeASTs(fragASTs ~ mainAst);
            fragAST = GlslUtils.generateFragmentAST(fragAST);
            import std.stdio;
            writeln(fragAST.getCode());
            auto vertAST = GlslUtils.generateVertexAST(fragAST);
            return [vertAST, fragAST];
        }

        this(Material mat) {
            this(mat, s => s);
        }

        this(Material mat, string delegate(string) replace) {
            static if(__traits(hasMember, typeof(this), "constructor")) {
                constructor(mat);
            }
            foreach (uni; this.getUniforms) {
                uni.setName(replace(uni.getName()));
                mat.setUniform(() => uni);
            }
        }
    }

}
