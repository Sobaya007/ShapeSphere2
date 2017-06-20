module sbylib.material.LambertMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.glsl.UniformDemand;
import sbylib.material.glsl.GlslUtils;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.Shader;
import sbylib.wrapper.gl.Program;
import sbylib.utils.Watcher;
import sbylib.setting;

class LambertMaterial : Material {
    enum FRAG_ROOT = SOURCE_ROOT ~ "sbylib/material/lambert/LambertMaterial.frag";
    static UniformDemand[] uniformDemands;
    static Shader vertexShader;
    static Shader fragmentShader;

    uvec3 ambient = new uvec3("ambient");
    uvec3 diffuse = new uvec3("diffuse");

    this() {
        if (!uniformDemands) {
            auto asts = MaterialUtils.generateAstFromFragmentPath(FRAG_ROOT);
            uniformDemands = GlslUtils.requiredUniformDemands(asts);
            vertexShader = new Shader(asts[0].getCode(), ShaderType.Vertex);
            fragmentShader = new Shader(asts[1].getCode(), ShaderType.Fragment);
        }
        const program = new Program([vertexShader, fragmentShader]);
        super(program);

        this.setUniform(() => this.ambient);
        this.setUniform(() => this.diffuse);
    }

    override UniformDemand[] getDemands() {
        return uniformDemands;
    }
}
