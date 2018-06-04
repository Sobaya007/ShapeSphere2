module game.stage.crystalMine.StageMaterial;

import sbylib;

class StageMaterial : Material {

    mixin ConfigureMaterial;

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

class StageMaterialBuilder : MaterialBuilder {

    mixin Singleton;
    override Material buildMaterial(immutable(XMaterial) xmat) {
        import std.string;
        import game.stage.crystalMine.CrystalMaterial;
        if (xmat.name.startsWith("Crystal")) return new CrystalMaterial;
        auto material = new StageMaterial();
        material.diffuse = xmat.diffuse.xyz;
        material.specular = xmat.specular;
        material.ambient = vec4(xmat.ambient, 1.0);
        material.power = xmat.power;
        material.name = xmat.name;
        return material;
    }
}
