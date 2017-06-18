module sbylib.material.LambertMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.glsl.Constants;
import sbylib.wrapper.gl.Uniform;
import sbylib.utils.Watcher;
import sbylib.setting;

class LambertMaterial : Material {
    enum FRAG_ROOT = SOURCE_ROOT ~ "sbylib/material/lambert/LambertMaterial.frag";
    this() {
        const shader = MaterialUtils.generateProgramFromFragmentPath(FRAG_ROOT);
        super(shader);
    }

    override UniformDemand[] getDemands() {
        enum result = [
            UniformDemand.World,
            UniformDemand.View,
            UniformDemand.Proj
            ];
        return result;
    }
}
