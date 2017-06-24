module sbylib.material.LambertMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;

class LambertMaterial : UniformKeeper {

    mixin MaterialUtils.declare;

    uvec3 ambient = new uvec3("ambient");
    uvec3 diffuse = new uvec3("diffuse");
}
