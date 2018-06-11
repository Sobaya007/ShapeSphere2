module game.stage.crystalMine.component.Crystal;

import sbylib;
import game.stage.crystalMine.component.Component;

struct Crystal {
    mixin Component!(CrystalEntity, ["pos" : "vec3", "color" : "vec3"]);
}

class CrystalEntity {

    Entity entity;
    private PointLight light;
    
    alias entity this;

    this() {
        auto loaded = XLoader().load(ModelPath("crystal.x"));

        import game.stage.crystalMine.StageMaterial;
        this.entity = loaded.buildEntity(StageMaterialBuilder());
        this.entity.buildCapsule();

        this.light = new PointLight(vec3(0), vec3(0));
        this.entity.addChild(this.light);
    }

    void color(vec3 diffuse) {
        this.light.diffuse = diffuse;
    }
}
