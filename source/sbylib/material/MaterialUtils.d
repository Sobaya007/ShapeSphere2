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

        Ast[2] generateAstFromFragmentPath(string path) {
            path = ROOT_PATH ~ path;
            auto fragSource = readText(path);
            auto ASTs = GlslUtils.generateAstFromFragmentSource(fragSource);
            return ASTs;
        }

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
        import sbylib.material.glsl.UniformDemand;
        import sbylib.wrapper.gl.Constants;
        import sbylib.wrapper.gl.Shader;
        import sbylib.wrapper.gl.Program;
        import sbylib.setting;
        import std.string;
        enum FRAG_ROOT = file.replace(".d", ".frag");
        static UniformDemand[] uniformDemands;
        static Shader vertexShader;
        static Shader fragmentShader;

        override UniformDemand[] getDemands() {
            return uniformDemands;
        }
    }

    static string init() {
        return q{
            import sbylib.wrapper.gl.Shader;
            import sbylib.wrapper.gl.Program;
            import sbylib.wrapper.gl.Constants;
            import sbylib.material.glsl.GlslUtils;
            if (!uniformDemands) {
                auto asts = MaterialUtils.generateAstFromFragmentPath(FRAG_ROOT);
                uniformDemands = GlslUtils.requiredUniformDemands(asts);
                vertexShader = new Shader(asts[0].getCode(), ShaderType.Vertex);
                fragmentShader = new Shader(asts[1].getCode(), ShaderType.Fragment);
            }
            const program = new Program([vertexShader, fragmentShader]);
            super(program);
        };
    }
}
