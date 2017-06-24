module sbylib.material.UvMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;

class UvMaterialUniformKeeper : UniformKeeper {
    mixin MaterialUtils.declare;
}

alias UvMaterial = MaterialTemp!UvMaterialUniformKeeper;
