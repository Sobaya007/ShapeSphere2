module sbylib.material.LambertMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;
import sbylib.math.Vector;

class LambertMaterial : Material {

    mixin ConfigureMaterial;

    uvec3 ambient;
    uvec3 diffuse;
    uvec3 fogColor;
    ufloat fogDensity;

    this() {

        mixin(autoAssignCode);
        super();

        this.ambient = vec3(0);
        this.diffuse = vec3(0);
        this.fogColor = vec3(0);
        this.fogDensity = 0.00;
    }
}
