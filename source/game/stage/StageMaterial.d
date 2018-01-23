module game.stage.StageMaterial;

import sbylib;

class StageMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    uvec3 diffuse;
    uvec3 specular;
    uvec4 ambient;
    ufloat power;
    string name;

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

alias StageMaterial = MaterialTemp!(StageMaterialUniformKeeper);
