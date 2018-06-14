module sbylib.material.DiscardMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;
import sbylib.math.Vector;

class DiscardMaterial : Material {

    mixin ConfigureMaterial;

    this() {
        mixin(autoAssignCode);
        super();
    }
}
