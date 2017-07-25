module sbylib.material.PhongMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformTexture;
import sbylib.math.Vector;

class PhongMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    uvec4 diffuse;
    uvec3 specular;
    uvec3 ambient;
    ufloat power;

    ubool hasTexture;
    utexture texture;

    void constructor() {
        this.diffuse = new uvec4("diffuse");
        this.ambient = new uvec3("ambient");
        this.specular = new uvec3("specular");
        this.power = new ufloat("power");
        this.hasTexture = new ubool("hasTexture");
        this.texture = new utexture("texture");
        this.diffuse = vec4(0);
        this.ambient = vec3(0);
        this.specular = vec3(0);
        this.power = 0.0;
        this.hasTexture = false;
    }
}

alias PhongMaterial = MaterialTemp!PhongMaterialUniformKeeper;
