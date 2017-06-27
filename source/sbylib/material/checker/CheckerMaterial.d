module sbylib.material.CheckerMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformTexture;

class CheckerMaterialUniformMaterial(Material0, Material1) : UniformKeeper {
    enum MaterialName1 = "Material0";
    enum MaterialName2 = "Material1";
    mixin MaterialUtils.declareMix!(Material0, Material1);
    ufloat size = new ufloat("size");
}

alias CheckerMaterial(Material0, Material1) = MaterialTemp!(CheckerMaterialUniformMaterial!(Material0, Material1));
