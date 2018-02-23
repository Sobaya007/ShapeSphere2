module game.tool.manipulator.Manipulator;

import sbylib;
import game.Game;
import game.tool.manipulator;

class Manipulator {

public:
    Entity entity;

private:
    Entity target;

public:
    this() {
        buildEntity();
    }

    void setTarget(Entity target) {
        this.target = target;
        entity.pos = target.pos.get;
    }

private:
    void buildEntity() {
        this.entity = new Entity;
        this.entity.pos = vec3(20, 2, 5);

        this.entity.addChild(createArrow(vec3(1, 0, 0), vec3(0.6, 0.1, 0.1)));
        this.entity.addChild(createArrow(vec3(0, 1, 0), vec3(0.1, 0.6, 0.1)));
        this.entity.addChild(createArrow(vec3(0, 0, 1), vec3(0.1, 0.1, 0.6)));
    }

    Entity createArrow(vec3 direction, vec3 diffuse) {
        auto arrow = makeEntity(Pole.create(0.2, 5, 16), new LambertMaterial);
        auto head = makeEntity(Pole.create(0.4, 0.5, 16), new LambertMaterial);

        head.pos = vec3(0, 5/2.0, 0);
        arrow.addChild(head);
        arrow.rot = mat3.rotFromTo(vec3(0, 1, 0), direction);

        arrow.ambient = vec3(0.2, 0.2, 0.2);
        head.ambient = vec3(0.2, 0.2, 0.2);
        arrow.diffuse = diffuse;
        head.diffuse = diffuse;

        return arrow;
    }

}
