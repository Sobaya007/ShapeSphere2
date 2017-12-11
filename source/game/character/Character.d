module game.character.Character;

import game.command;
import game.player.BaseSphere;
import game.player.ElasticSphere;
import game.character.CharacterMaterial;
import sbylib;
import std.algorithm, std.array;
import std.math;

class Character {

    enum DOWN_PUSH_FORCE = 600;
    enum DOWN_PUSH_FORE_MIN = 800;
    enum SIDE_PUSH_FORCE = 10;
    enum TIME_STEP = 0.02;

    Entity[] floors;
    private ElasticSphere2 elasticSphere;
    Entity sphere;
    private int count;

    this(World world) {
        {
            auto mat = new CharacterMaterial();
            mat.config.transparency = true;
            mat.config.depthWrite = false;
            mat.config.faceMode = FaceMode.Front;
            this.elasticSphere = new ElasticSphere2(mat);
            this.elasticSphere.setCenter(vec3(2, 10, 2));
            world.add(elasticSphere.entity);
        }
        {
            auto mat = new ColorMaterial;
            mat.color = vec4(1,0.5, 0.5, 0.5);
            this.sphere = new Entity(Sphere.create(1.2, 3), mat, new CollisionCapsule(1.2, vec3(0), vec3(0)));
            mat.config.polygonMode = PolygonMode.Line;
            this.elasticSphere.entity.addChild(sphere);
        }
    }

    void step() {
        this.elasticSphere.move(floors);
        auto c = count++ % 100;
        if (c < 10) {
            this.elasticSphere.push(vec3(0,-200,0), 10000);
        }
    }
}
