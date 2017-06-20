module sbylib.material.NormalMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.wrapper.gl.Uniform;

class NormalMaterial : Material {

    mixin MaterialUtils.declare;

    this() {
        mixin(MaterialUtils.init());
    }
}
