module sbylib.material.UvMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;

class UvMaterial : Material {
    mixin ConfigureMaterial;

    this() {
        mixin(autoAssignCode);
        super();
    }
}
