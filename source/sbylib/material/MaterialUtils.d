module sbylib.material.MaterialUtils;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Shader;
import sbylib.wrapper.gl.Program;
import sbylib.setting;
import sbylib.material.glsl.GlslUtils;
import std.file;

class MaterialUtils {

    private this(){}

    static {

        const(Program) generateProgramFromFragmentPath(string path) {
            path = ROOT_PATH ~ path;
            auto fragSource = readText(path);
            auto ASTs = GlslUtils.createShaders(fragSource);
            auto vert = new Shader(ASTs[0].getCode(), ShaderType.Vertex);
            auto frag = new Shader(ASTs[1].getCode(), ShaderType.Fragment);
            return new Program([vert, frag]);
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
}
