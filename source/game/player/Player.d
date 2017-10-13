module game.player.Player;

import game.command;
import game.player.BaseSphere;
import game.player.ElasticSphere;
import game.player.NeedleSphere;
import game.player.PlayerMaterial;
import sbylib;
import std.algorithm, std.array;
import std.math;

class Player {

    alias Mat = ConditionalMaterial!(LambertMaterial, PlayerMaterial);
    alias PlayerEntity = EntityTemp!(GeometryN, Mat);

    enum DOWN_PUSH_FORCE = 600;
    enum DOWN_PUSH_FORE_MIN = 800;
    enum SIDE_PUSH_FORCE = 10;
    enum TIME_STEP = 0.02;

    Entity floors;
    private BaseSphere sphere;
    private ElasticSphere elasticSphere;
    private NeedleSphere needleSphere;
    private Key key;
    package World world;
    Camera camera;
    flim pushCount;
    CommandSpawner[] commandSpawners;

    this(Key key, Camera camera, World world) {
        this.world = world;
        this.floors = new Entity();
        this.elasticSphere = new ElasticSphere(this);
        this.needleSphere = new NeedleSphere(this);
        this.sphere = this.elasticSphere;
        this.key = key;
        this.camera = camera;
        this.pushCount = flim(0.0, 0.0, 1);
        this.commandSpawners = [
            new CommandSpawner(() => key.isPressed(KeyButton.Space), new Command(&this.onDownPress)),
            new CommandSpawner(() => key.justReleased(KeyButton.Space), new Command(&this.onDownJustRelease)),
            new CommandSpawner(() => key.isPressed(KeyButton.KeyX), new Command(&this.onNeedlePress)),
            new CommandSpawner(() => key.isReleased(KeyButton.KeyX), new Command(&this.onNeedleRelease)),
            new CommandSpawner(() => key.isPressed(KeyButton.Left), new Command(&this.onLeftPress)),
            new CommandSpawner(() => key.isPressed(KeyButton.Right), new Command(&this.onRightPress)),
            new CommandSpawner(() => key.isPressed(KeyButton.Up), new Command(&this.onForwardPress)),
            new CommandSpawner(() => key.isPressed(KeyButton.Down), new Command(&this.onBackPress))];
        this.world.add(sphere.getEntity());
    }

    void step() {
        this.sphere.move();
    }

    void onDownPress() {
        this.sphere.onDownPress();
    }

    void onDownJustRelease() {
        this.sphere.onDownJustRelease();
    }

    void onNeedlePress() {
        if (this.sphere !is this.needleSphere) {
            this.needleSphere.fromElastic(this.elasticSphere);
            this.sphere.leave();
            this.sphere = this.needleSphere;
        }
        this.needleSphere.onNeedlePress();
    }

    void onNeedleRelease() {
        if (this.sphere != this.needleSphere) return;
        this.sphere.onNeedleRelease();
        if (this.needleSphere.hasFinished) {
            this.sphere.leave();
            this.sphere = this.elasticSphere;
            this.elasticSphere.fromNeedle(this.needleSphere);
        }
    }

    void onLeftPress() {
        this.sphere.onLeftPress();
    }

    void onRightPress() {
        this.sphere.onRightPress();
    }

    void onForwardPress() {
        this.sphere.onForwardPress();
    }

    void onBackPress() {
        this.sphere.onBackPress();
    }

    Entity getEntity() {
        return this.sphere.getEntity();
    }
}
