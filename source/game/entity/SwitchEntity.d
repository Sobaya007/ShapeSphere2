module game.entity.SwitchEntity;

import sbylib;

import game.event.Event;

class SwitchEntity {

    Entity entity;
    alias entity this;
    
    private Event event;
    private float dy;

    private mixin DeclareConfig!(float, "DOWN_SPEED", "switch.json");
    private mixin DeclareConfig!(float, "DOWN_MAX", "switch.json");
    private mixin DeclareConfig!(float, "SIZE", "switch.json");
    private mixin DeclareConfig!(float, "DEPTH", "switch.json");

    this() {
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
            //event.fire();
            return;
        }
        dy += DOWN_SPEED;
        this.pos.y -= DOWN_SPEED;
    }
}
