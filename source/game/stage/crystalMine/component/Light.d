module game.stage.crystalMine.component.Light;

import sbylib;
import game.stage.crystalMine.component.Component;

struct Light {
    mixin Component!(LightEntity, ["pos" : "vec3", "color" : "vec3"]);
}

class LightEntity {

    PointLight entity;

    alias entity this;

    this() {
        this.entity = new PointLight(vec3(0), vec3(0));
    }

    void color(vec3 diffuse) {
        this.entity.diffuse = diffuse;
    }
}
