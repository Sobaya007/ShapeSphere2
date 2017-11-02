module game.player.Player;

import game.command;
import game.player.BaseSphere;
import game.player.ElasticSphere;
import game.player.NeedleSphere;
import game.player.SpringSphere;
import game.player.PlayerMaterial;
import game.player.Controler;
import game.player.PlayerChaseControl;
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
    private Controler controler;
    package World world;
    private Camera camera;
    private PlayerChaseControl cameraControl;

    this(Key key, JoyStick joy, Camera camera, World world, ICommandManager commandManager) {
        this.world = world;
        this.camera = camera;
        this.cameraControl = new PlayerChaseControl(camera, this);
        this.floors = new Entity();
        this.elasticSphere = new ElasticSphere(this, camera, world, this.cameraControl);
        this.needleSphere = new NeedleSphere(this);
        this.springSphere = new SpringSphere(this, camera, this.cameraControl);
        this.elasticSphere.constructor(this.needleSphere, this.springSphere);
        this.needleSphere.constructor(this.elasticSphere);
        this.springSphere.constructor(this.elasticSphere);
        this.sphere = this.elasticSphere;
        this.controler = new Controler(key, joy);
        commandManager.addCommand(new ButtonCommand(() => controler.isPressed(ControlerButton.Down), &this.onDownPress));
        commandManager.addCommand(new ButtonCommand(() => controler.justReleased(ControlerButton.Down), &this.onDownJustRelease));
        commandManager.addCommand(new ButtonCommand(() => controler.isPressed(ControlerButton.Needle), &this.onNeedlePress));
        commandManager.addCommand(new ButtonCommand(() => controler.isReleased(ControlerButton.Needle), &this.onNeedleRelease));
        commandManager.addCommand(new ButtonCommand(() => controler.isPressed(ControlerButton.Spring), &this.onSpringPress));
        commandManager.addCommand(new ButtonCommand(() => controler.justReleased(ControlerButton.Spring), &this.onSpringJustRelease));
        commandManager.addCommand(new ButtonCommand(() => controler.justPressed(ControlerButton.CameraReset), &this.onCameraResetJustPress));
        commandManager.addCommand(new ButtonCommand(() => controler.justPressed(ControlerButton.LookOver), &this.onLookOverJustPress));
        commandManager.addCommand(new ButtonCommand(() => controler.justReleased(ControlerButton.LookOver), &this.onLookOverJustRelease));
        commandManager.addCommand(new StickCommand(() => controler.getLeftStickValue.safeNormalize, &this.onMovePress));
        commandManager.addCommand(new StickCommand(() => controler.getRightStickValue.safeNormalize, &this.onRotatePress));
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

    void onMovePress(vec2 v) {
        this.sphere = this.sphere.onMovePress(v);
    }

    void onRotatePress(vec2 v) {
        // なぜかyが死ぬ
        this.cameraControl.turn(v.x);
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

    void onCameraResetJustPress() {
        this.cameraControl.reset();
    }

    void onLookOverJustPress() {
        this.sphere.requestLookOver();
    }

    void onLookOverJustRelease() {
        this.cameraControl.stopLookOver();
    }

    vec3 getCameraTarget() {
        return this.sphere.getCameraTarget;
    }

    Maybe!vec3 getLastDirection() {
        if (this.sphere !is this.elasticSphere) {
            return None!vec3;
        }
        auto v = this.elasticSphere.getLinearVelocity;
        if (v.length < 1e-2) return None!vec3;
        return Just(normalize(v));
    }

}
