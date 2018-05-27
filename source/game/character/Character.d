module game.character.Character;

import game.Game;
import game.entity.Message;
import game.command;
import game.player;
import game.character.CharacterMaterial;
import sbylib;
import dconfig;
import std.algorithm, std.array, std.math, std.json, std.conv;

class Character {

    mixin HandleConfig;
    @config(ConfigPath("player.json")) float TIME_STEP;

    Entity[] floors;
    ElasticSphere2 elasticSphere;
    Entity collisionArea;
    private Entity activeArea;
    private int count;
    dstring serif;

    alias elasticSphere this;

    this() {
        this.initializeConfig();
        {
            auto mat = new CharacterMaterial();
            mat.config.renderGroupName = "transparent";
            mat.config.faceMode = FaceMode.Front;
            this.elasticSphere = new ElasticSphere2(mat);
        }
        this.collisionArea = new Entity(new CollisionCapsule(1.2, vec3(0), vec3(0)));
        this.collisionArea.name = "Character's Collision Area";
        this.activeArea = new Entity(new CollisionCapsule(2, vec3(0), vec3(0)));
        this.activeArea.name = "Character's Active Area";
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
        auto charas = 
            info.map!(colInfo => colInfo.entity.getUserData!(Player))
            .catMaybe;
        auto c = count % 100;

        if (charas.empty && c == 1) return;

        count++;

        this.elasticSphere.move([]);
        if (c < 10) {
            this.elasticSphere.push(vec3(0,-200,0), 10000);
        }
    }

    void talk(void delegate() onFinish) {
        auto message = Game.getMessge();
        message.setMessage(this.serif, onFinish);
        Game.getWorld2D().add(message);
        Game.getCommandManager().setReceiver(message);
    }
}
