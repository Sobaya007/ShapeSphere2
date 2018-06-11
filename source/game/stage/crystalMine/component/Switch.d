module game.stage.crystalMine.component.Switch;

import sbylib;
import game.stage.crystalMine.component.Component;
import game.entity.SwitchEntity;

class SwitchEntity2 {

    SwitchEntity entity;

    alias entity this;

    this() {
        this.entity = new SwitchEntity;
    }

    void angle(float a) {
        this.entity.rot = mat3.axisAngle(vec3(0,1,0), a.rad);
    }
}

struct Switch {
    mixin Component!(SwitchEntity2, ["pos" : "vec3", "angle" : "float"]);
}
