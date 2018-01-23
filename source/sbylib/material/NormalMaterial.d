module sbylib.material.NormalMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;

class NormalMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;
}

alias NormalMaterial = MaterialTemp!NormalMaterialUniformKeeper;
