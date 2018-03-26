module game.entity.Switch;

import sbylib;

import game.event.Event;

class Switch {

    Entity entity;
    alias entity this;
    
    private vec3 defPos;
    private float dy = 0;
    private Event event;

    this(vec3 pos) {
        this.entity = XLoader.load(ModelPath("switch.x")).buildEntity();
        this.entity.buildBVH();
        this.entity.pos = pos;
        this.defPos = pos;
    }

    void step() {
        if (dy > 0) dy *= 0.9;
        entity.pos.y = defPos.y + dy;
    }

    void onDownPress() {
        dy += 0.01;

        if (dy > 1) {
            dy = 1;
            event.fire();
        }
    }
}
