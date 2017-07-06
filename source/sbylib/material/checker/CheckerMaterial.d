module sbylib.material.CheckerMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformTexture;

class CheckerMaterialUniformMaterial(Material1, Material2) : UniformKeeper {
    enum MaterialName1 = "Material1";
    enum MaterialName2 = "Material2";
    mixin MaterialUtils.declareMix!(Material1, Material2);
    ufloat size;

    void constructor() {
        this.size = new ufloat("size");
    }
}

alias CheckerMaterial(Material1, Material2) = MaterialTemp!(CheckerMaterialUniformMaterial!(Material1, Material2));
