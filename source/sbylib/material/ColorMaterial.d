module sbylib.material.ColorMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;
import sbylib.math.Vector;

class ColorMaterial : Material {

    uvec4 color;

    mixin declare;

    this() {
        mixin(autoAssignCode);
        super();
        color = vec4(1);
    }
}
