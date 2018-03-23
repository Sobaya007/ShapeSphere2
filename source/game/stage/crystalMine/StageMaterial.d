module game.stage.crystalMine.StageMaterial;

import sbylib;

class StageMaterial : Material {

    mixin declare;

    uvec3 diffuse;
    uvec3 specular;
    uvec4 ambient;
    ufloat power;
    string name;

    ufloat b;

    this() {
        mixin(autoAssignCode);
        super();

        this.diffuse = vec3(0);
        this.specular = vec3(0);
        this.ambient = vec4(0);
        this.power = 0.0f;
    }
}
