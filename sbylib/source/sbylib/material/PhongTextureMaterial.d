module sbylib.material.PhongTextureMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformTexture;
import sbylib.math.Vector;

class PhongTextureMaterial : Material {

    mixin ConfigureMaterial;

    uvec3 diffuse;
    uvec3 specular;
    uvec4 ambient;
    ufloat power;
    utexture texture;

    this() {

        mixin(autoAssignCode);
        super();

        this.diffuse = vec3(0);
        this.specular = vec3(0);
        this.ambient = vec4(0);
        this.power = 0.0;
    }
}
