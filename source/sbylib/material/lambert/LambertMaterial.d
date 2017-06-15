module sbylib.material.LambertMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.GlslUtils;
import sbylib.material.Constants;
import sbylib.wrapper.gl.Uniform;
import sbylib.utils.Watcher;
import sbylib.setting;

class LambertMaterial : Material {
    enum VERT_ROOT = SOURCE_ROOT ~ "sbylib/material/lambert/LambertMaterial.vert";
    enum FRAG_ROOT = SOURCE_ROOT ~ "sbylib/material/lambert/LambertMaterial.frag";
    this() {
        const shader = MaterialUtils.generateProgramFromFragmentPath(FRAG_ROOT);
        //const shader = MaterialUtils.createProgramFromPath(VERT_ROOT, FRAG_ROOT);
        super(shader);
    }

    override UniformDemand[] createDemands() {
        return [
        UniformDemand.WorldMatrix,
        UniformDemand.ViewMatrix,
        UniformDemand.ProjMatrix
        ];
    }
}
