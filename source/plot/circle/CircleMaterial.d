module plot.circle.CircleMaterial;

import sbylib;

class CircleMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    uvec3 color;

    void constructor() {
        this.color = new uvec3("color");
        this.color = vec3(1);
    }
}

alias CircleMaterial = MaterialTemp!CircleMaterialUniformKeeper;
