module sbylib.material.ColorMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.math.Vector;

class ColorMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    uvec4 color;

    void constructor() {
        this.color = new uvec4("color");
    }
}

alias ColorMaterial = MaterialTemp!ColorMaterialUniformKeeper;
