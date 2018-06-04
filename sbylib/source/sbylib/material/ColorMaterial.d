module sbylib.material.ColorMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;
import sbylib.math.Vector;

class ColorMaterial : Material {

    uvec4 color;

    mixin ConfigureMaterial;

    this() {
        mixin(autoAssignCode);
        super();
        this.color = vec4(1);
    }

    this(vec4 color) {
        mixin(autoAssignCode);
        super();
        this.color = color;
    }
}
