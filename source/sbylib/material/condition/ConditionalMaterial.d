module sbylib.material.ConditionalMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.wrapper.gl.Uniform;

class ConditionalMaterial : Material {

    mixin MaterialUtils.declare;

    ubool condition;
    uvec3 trueColor;
    uvec3 falseColor;

    this() {
        mixin(MaterialUtils.init());

        this.condition = new ubool("condition");
        this.trueColor = new uvec3("trueColor");
        this.falseColor = new uvec3("falseColor");

        this.setUniform(() => this.condition);
        this.setUniform(() => this.trueColor);
        this.setUniform(() => this.falseColor);
    }
}
