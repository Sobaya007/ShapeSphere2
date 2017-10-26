module game.player.Player;

import game.command;
import game.player.BaseSphere;
import game.player.ElasticSphere;
import game.player.NeedleSphere;
import game.player.SpringSphere;
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
    private SpringSphere springSphere;
    private Key key;
    package World world;
    private Camera camera;
    private CameraChaseControl cameraControl;

    this(Key key, Camera camera, World world, CommandManager commandManager) {
        this.world = world;
        this.floors = new Entity();
        this.elasticSphere = new ElasticSphere(this, camera, world);
        this.needleSphere = new NeedleSphere(this);
        this.springSphere = new SpringSphere(this);
        this.elasticSphere.constructor(this.needleSphere, this.springSphere);
        this.needleSphere.constructor(this.elasticSphere);
        this.springSphere.constructor(this.elasticSphere);
        this.sphere = this.elasticSphere;
        this.key = key;
        this.camera = camera;
        commandManager.addSpawner(new CommandSpawner(() => key.isPressed(KeyButton.Space), new Command(&this.onDownPress)));
        commandManager.addSpawner(new CommandSpawner(() => key.justReleased(KeyButton.Space), new Command(&this.onDownJustRelease)));
        commandManager.addSpawner(new CommandSpawner(() => key.isPressed(KeyButton.KeyX), new Command(&this.onNeedlePress)));
        commandManager.addSpawner(new CommandSpawner(() => key.isReleased(KeyButton.KeyX), new Command(&this.onNeedleRelease)));
        commandManager.addSpawner(new CommandSpawner(() => key.isPressed(KeyButton.KeyC), new Command(&this.onSpringPress)));
        commandManager.addSpawner(new CommandSpawner(() => key.justReleased(KeyButton.KeyC), new Command(&this.onSpringJustRelease)));
        commandManager.addSpawner(new CommandSpawner(() => key.isPressed(KeyButton.Left), new Command(&this.onLeftPress)));
        commandManager.addSpawner(new CommandSpawner(() => key.isPressed(KeyButton.Right), new Command(&this.onRightPress)));
        commandManager.addSpawner(new CommandSpawner(() => key.isPressed(KeyButton.Up), new Command(&this.onForwardPress)));
        commandManager.addSpawner(new CommandSpawner(() => key.isPressed(KeyButton.Down), new Command(&this.onBackPress)));
        this.cameraControl = new CameraChaseControl(camera, () => this.sphere.getCameraTarget);
    }

    void step() {
        this.sphere = this.sphere.move();
        this.cameraControl.step();
    }

    void onDownPress() {
        this.sphere = this.sphere.onDownPress();
    }

    void onDownJustRelease() {
        this.sphere = this.sphere.onDownJustRelease();
    }

    void onLeftPress() {
        this.sphere = this.sphere.onLeftPress();
    }

    void onRightPress() {
        this.sphere = this.sphere.onRightPress();
    }

    void onForwardPress() {
        this.sphere = this.sphere.onForwardPress();
    }

    void onBackPress() {
        this.sphere = this.sphere.onBackPress();
    }

    void onNeedlePress() {
        this.sphere = this.sphere.onNeedlePress();
    }

    void onNeedleRelease() {
        this.sphere = this.sphere.onNeedleRelease();
    }

    void onSpringPress() {
        this.sphere = this.sphere.onSpringPress();
    }

    void onSpringJustRelease() {
        this.sphere = this.sphere.onSpringJustRelease();
    }
}
