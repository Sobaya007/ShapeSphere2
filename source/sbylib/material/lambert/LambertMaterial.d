module sbylib.material.LambertMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.math.Vector;

class LambertMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    uvec3 ambient;
    uvec3 diffuse;
    uvec3 fogColor;
    ufloat fogDensity;

    void constructor() {
        this.ambient = new uvec3("ambient");
        this.diffuse = new uvec3("diffuse");
        this.fogColor = new uvec3("fogColor");
        this.fogDensity = new ufloat("fogDensity");
        this.ambient = vec3(0);
        this.diffuse = vec3(0);
        this.fogColor = vec3(0);
        this.fogDensity = 0.00;
    }
}

alias LambertMaterial = MaterialTemp!LambertMaterialUniformKeeper;
