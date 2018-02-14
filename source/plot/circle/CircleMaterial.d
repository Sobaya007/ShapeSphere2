module plot.circle.CircleMaterial;

import sbylib;

class CircleMaterial : Material {

    mixin declare;

    uvec3 color;

    this() {
        mixin(autoAssignCode);
        this.color = vec3(1);
    }
}
