module sbylib.material.ConditionalMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformTexture;

class ConditionalMaterialUniformMaterial(TrueMaterial, FalseMaterial) : UniformKeeper {
    enum MaterialName1 = "TrueMaterial";
    enum MaterialName2 = "FalseMaterial";
    mixin MaterialUtils.declareMix!(TrueMaterial, FalseMaterial);
    ubool condition = new ubool("condition");
}

alias ConditionalMaterial(TrueMaterial, FalseMaterial) = MaterialTemp!(ConditionalMaterialUniformMaterial!(TrueMaterial, FalseMaterial));
