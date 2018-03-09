module sbylib.material.ConditionalMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformTexture;

class ConditionalMaterial(TrueMaterial, FalseMaterial) : Material {
    enum MaterialName1 = "TrueMaterial";
    enum MaterialName2 = "FalseMaterial";

    mixin declareMix!(TrueMaterial, FalseMaterial);

    ubool condition;

    this() {
        mixin(autoAssignCode);
        initialize();
        super();
    }
}

