module sbylib.material.LambertMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.glsl.UniformDemand;
import sbylib.wrapper.gl.Uniform;
import sbylib.utils.Watcher;
import sbylib.setting;

class LambertMaterial : Material {
    enum FRAG_ROOT = SOURCE_ROOT ~ "sbylib/material/lambert/LambertMaterial.frag";

    uvec3 ambient = new uvec3("ambient");
    uvec3 diffuse = new uvec3("diffuse");

    this() {
        const shader = MaterialUtils.generateProgramFromFragmentPath(FRAG_ROOT);
        super(shader);

        this.setUniform(() => this.ambient);
        this.setUniform(() => this.diffuse);
    }

    override UniformDemand[] getDemands() {
        enum result = [
            UniformDemand.World,
            UniformDemand.View,
            UniformDemand.Proj,
            UniformDemand.Light
            ];
        return result;
    }
}
