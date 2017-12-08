module game.player.Character;

import game.command;
import game.player.BaseSphere;
import game.player.ElasticSphere;
import game.player.Controller;
import sbylib;
import std.algorithm, std.array;
import std.math;

class Character {

    enum DOWN_PUSH_FORCE = 600;
    enum DOWN_PUSH_FORE_MIN = 800;
    enum SIDE_PUSH_FORCE = 10;
    enum TIME_STEP = 0.02;

    Entity floors;
    private ElasticSphere2 elasticSphere;
    private int count;

    this(World world) {
        this.floors = new Entity();
        this.elasticSphere = new ElasticSphere2();
        this.elasticSphere.setCenter(vec3(2, 10, 2));
        world.add(elasticSphere.entity);
    }

    void step() {
        this.elasticSphere.move(floors);
        auto c = count++ % 100;
        if (c < 10) {
            this.elasticSphere.push(vec3(0,-200,0), 10000);
        }
    }
}
