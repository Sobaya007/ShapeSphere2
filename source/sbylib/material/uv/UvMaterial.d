module sbylib.material.UvMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.wrapper.gl.Uniform;

class UvMaterial : Material {

    mixin MaterialUtils.declare;

    this() {
        mixin(MaterialUtils.init());
    }
}
