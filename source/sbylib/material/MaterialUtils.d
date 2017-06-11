module sbylib.material.MaterialUtils;

import sbylib.gl.Constants;
import sbylib.gl.Shader;
import sbylib.setting;
import std.file;

class MaterialUtils {

    private this(){}

    static {
        const(Shader) createShaderFromPath(string path, ShaderType type) {
            path = ROOT_PATH ~ path;
            immutable source = readText(path);
            return new Shader(source, type);
        }

        const(ShaderProgram) createProgramFromPath(string vertPath, string fragPath, string geomPath = null) {
            auto vert = createShaderFromPath(vertPath, ShaderType.Vertex);
            auto frag = createShaderFromPath(fragPath, ShaderType.Fragment);
            auto shaders = [vert, frag];
            if (geomPath) {
                auto geom = createShaderFromPath(geomPath, ShaderType.Geometry);
                shaders ~= geom;
            }
            return new ShaderProgram(shaders);
        }
    }
}
