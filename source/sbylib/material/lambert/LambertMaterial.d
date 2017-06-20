module sbylib.material.LambertMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.wrapper.gl.Uniform;

class LambertMaterial : Material {

    mixin MaterialUtils.declare;

    uvec3 ambient = new uvec3("ambient");
    uvec3 diffuse = new uvec3("diffuse");

    this() {
        mixin(MaterialUtils.init());

        this.setUniform(() => this.ambient);
        this.setUniform(() => this.diffuse);
    }
}
