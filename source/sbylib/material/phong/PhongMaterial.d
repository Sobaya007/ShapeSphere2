module sbylib.material.PhongMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformTexture;
import sbylib.math.Vector;

class PhongMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    uvec3 diffuse;
    uvec3 specular;
    uvec4 ambient;
    ufloat power;

    void constructor() {
        this.diffuse = new uvec3("diffuse");
        this.specular = new uvec3("specular");
        this.ambient = new uvec4("ambient");
        this.power = new ufloat("power");
        this.diffuse = vec3(0);
        this.specular = vec3(0);
        this.ambient = vec4(0);
        this.power = 0.0;
    }
}

alias PhongMaterial = MaterialTemp!PhongMaterialUniformKeeper;
