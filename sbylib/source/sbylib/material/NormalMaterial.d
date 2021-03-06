module sbylib.material.NormalMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;

class NormalMaterial : Material {
    mixin ConfigureMaterial;

    this() {
        mixin(autoAssignCode);
        super();
    }
}
