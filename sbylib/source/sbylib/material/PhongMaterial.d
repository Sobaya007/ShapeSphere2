module sbylib.material.PhongMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformTexture;
import sbylib.math.Vector;

class PhongMaterial : Material {

    mixin ConfigureMaterial;

    uvec3 diffuse;
    uvec3 specular;
    uvec4 ambient;
    ufloat power;

    this() {

        mixin(autoAssignCode);
        super();

        this.diffuse = vec3(0);
        this.specular = vec3(1);
        this.ambient = vec4(0);
        this.power = 1.0;
    }
}
