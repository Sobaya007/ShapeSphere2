module sbylib.material.CheckerMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;

class CheckerMaterial(Material1, Material2) : Material {
    enum MaterialName1 = "Material1";
    enum MaterialName2 = "Material2";
    mixin declareMix!(Material1, Material2);
    ufloat size;

    this() {
        mixin(autoAssignCode);
        initialize();
        super();
        size = 0.2;
    }
}
