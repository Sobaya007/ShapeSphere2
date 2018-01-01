module game.character.Character;

import game.Game;
import game.entity.Message;
import game.command;
import game.player;
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
    ElasticSphere2 elasticSphere;
    Entity collisionArea;
    private Entity activeArea;
    private int count;
    private dstring serif;

    alias elasticSphere this;

    this(World world, dstring serif) {
        this.serif = serif;
        {
            auto mat = new CharacterMaterial();
            mat.config.transparency = true;
            mat.config.depthWrite = false;
            mat.config.faceMode = FaceMode.Front;
            this.elasticSphere = new ElasticSphere2(mat);
            this.elasticSphere.setCenter(vec3(2, 10, 2));
            world.add(elasticSphere.entity);
        }
        this.collisionArea = new Entity(new CollisionCapsule(1.2, vec3(0), vec3(0)));
        this.collisionArea.setName("Character's Collision Area");
        this.activeArea = new Entity(new CollisionCapsule(2, vec3(0), vec3(0)));
        this.activeArea.setName("Character's Active Area");
        this.elasticSphere.entity.addChild(collisionArea);
        this.elasticSphere.entity.addChild(activeArea);
        elasticSphere.entity.setUserData(this);
    }

    void initialize() {
        foreach (i; 0..2) {
            elasticSphere.move([]);
        }
    }

    void step() {
        auto info = Array!CollisionInfoByQuery(0);
        scope(exit) info.destroy();
        Game.getWorld3D().queryCollide(info, this.activeArea);
        auto charas = info.map!(colInfo => colInfo.entity.getUserData.fmapAnd!((Variant data) {
            return wrap(data.peek!(Player));
        })).filter!(player => player.isJust).map!(player => player.get);
        auto c = count % 100;

        if (charas.empty && c == 1) return;

        count++;

        this.elasticSphere.move([]);
        if (c < 10) {
            this.elasticSphere.push(vec3(0,-200,0), 10000);
        }
    }

    void talk(void delegate() onFinish) {
        auto message = new Message(this.serif, onFinish);
        Game.getWorld2D().add(message);
        Game.getCommandManager().setReceiver(message);
    }
}
