module game.entity.SwitchEntity;

import sbylib;
import dconfig;

import game.event.Event;

class SwitchEntity {

    Entity entity;
    alias entity this;
    
    private float dy;

    mixin HandleConfig;

    @config(ConfigPath("switch.json")) {
        float DOWN_SPEED;
        float DOWN_MAX;
        float SIZE;
        float DEPTH;
    }
    
    void delegate() event;

    this() {
        this.initializeConfig();
        //this.entity = XLoader.load(ModelPath("switch.x")).buildEntity();
        this.entity = makeEntity(Box.create(), new NormalMaterial);
        this.entity.scale = vec3(SIZE, DEPTH, SIZE);
        this.entity.buildBVH();
        this.entity.name = "Switch";

        this.dy = 0;
    }

    void down() {

        if (dy >= DOWN_MAX) {
            dy = DOWN_MAX;
            if (event) {
                event();
                event = null;
            }
            return;
        }
        dy += DOWN_SPEED;
        this.pos.y -= DOWN_SPEED;
    }
}
