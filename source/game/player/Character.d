module game.player.Character;

/*
import game.command;
import game.player.BaseSphere;
import game.player.ElasticSphere;
import game.player.SpringSphere;
import game.player.PlayerMaterial;
import game.player.Controller;
import sbylib;
import std.algorithm, std.array;
import std.math;

class Character {

    alias Mat = ConditionalMaterial!(LambertMaterial, PlayerMaterial);
    alias PlayerEntity = EntityTemp!(GeometryN, Mat);

    enum DOWN_PUSH_FORCE = 600;
    enum DOWN_PUSH_FORE_MIN = 800;
    enum SIDE_PUSH_FORCE = 10;
    enum TIME_STEP = 0.02;

    Entity floors;
    private BaseSphere sphere;
    private ElasticSphere elasticSphere;
    private Controller controller;
    package World world;

    this(World world, ICommandManager commandManager) {
        this.world = world;
        this.floors = new Entity();
        this.elasticSphere = new ElasticSphere(this, camera, world, this.cameraControl);
        this.needleSphere = new NeedleSphere(this);
        this.springSphere = new SpringSphere(this, camera, this.cameraControl);
        this.elasticSphere.constructor(this.needleSphere, this.springSphere);
        this.needleSphere.constructor(this.elasticSphere);
        this.springSphere.constructor(this.elasticSphere);
        this.sphere = this.elasticSphere;
        this.controller = Controller();
        commandManager.addCommand(new ButtonCommand(() => controller.isPressed(CButton.Press), &this.onDownPress));
        commandManager.addCommand(new ButtonCommand(() => controller.justReleased(CButton.Press), &this.onDownJustRelease));
        commandManager.addCommand(new ButtonCommand(() => controller.isPressed(CButton.Needle), &this.onNeedlePress));
        commandManager.addCommand(new ButtonCommand(() => controller.isReleased(CButton.Needle), &this.onNeedleRelease));
        commandManager.addCommand(new ButtonCommand(() => controller.isPressed(CButton.Spring), &this.onSpringPress));
        commandManager.addCommand(new ButtonCommand(() => controller.justReleased(CButton.Spring), &this.onSpringJustRelease));
        commandManager.addCommand(new ButtonCommand(() => controller.justPressed(CButton.CameraReset), &this.onCameraResetJustPress));
        commandManager.addCommand(new ButtonCommand(() => controller.isPressed(CButton.LookOver), &this.onLookOverPress));
        commandManager.addCommand(new ButtonCommand(() => controller.justReleased(CButton.LookOver), &this.onLookOverJustRelease));
        commandManager.addCommand(new StickCommand(() => controller.getLeftStickValue.safeNormalize, &this.onMovePress));
        commandManager.addCommand(new StickCommand(() => controller.getRightStickValue.safeNormalize, &this.onRotatePress));
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
        this.cameraControl.turn(vec2(v.x,0));
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

    void onLookOverPress() {
        if (this.cameraControl.isLooking) return;
        this.sphere.requestLookOver();
    }

    void onLookOverJustRelease() {
        this.cameraControl.stopLookOver();
    }

    vec3 getCameraTarget() {
        return this.sphere.getCameraTarget;
    }

    vec3 getLastDirection() {
        return this.sphere.lastDirection();
    }

}
*/
