module sbylib.material.UnrealFloorMaterial;

import sbylib.material.CheckerMaterial;
import sbylib.material.ColorMaterial;
import sbylib.wrapper.gl.Uniform;
import sbylib.math.Vector;

private alias Mat = CheckerMaterial!(ColorMaterial, ColorMaterial);

class UnrealFloorMaterial : CheckerMaterial!(Mat, Mat) {

    this() {

        super();

        this.size = 0.1;
        this.size1 = 0.1 / 8;
        this.size2 = 0.1 / 8;
        this.color11 = vec4(vec3(0.2), 1);
        this.color12 = vec4(vec3(0.3), 1);
        this.color21 = vec4(vec3(0.2), 1);
        this.color22 = vec4(vec3(0.1), 1);
    }
}
