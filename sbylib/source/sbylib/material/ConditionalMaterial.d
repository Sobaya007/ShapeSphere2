module sbylib.material.ConditionalMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;

class ConditionalMaterial(TrueMaterial, FalseMaterial) : Material {
    enum MaterialName1 = "TrueMaterial";
    enum MaterialName2 = "FalseMaterial";

    mixin ConfigureMixMaterial!(TrueMaterial, FalseMaterial);

    ubool condition;

    this() {
        mixin(autoAssignCode);
        initialize();
        super();
    }
}

