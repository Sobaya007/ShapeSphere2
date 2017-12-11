module game.player.Player;

import game.command;
import game.player.BaseSphere;
import game.player.ElasticSphere;
import game.player.NeedleSphere;
import game.player.SpringSphere;
import game.player.PlayerMaterial;
import game.player.Controller;
import game.camera.PlayerChaseCamera;
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

    Entity[] floors;
    private BaseSphere sphere;
    private ElasticSphere elasticSphere;
    private NeedleSphere needleSphere;
    private SpringSphere springSphere;
    private Controller controller;
    package World world;
    private PlayerChaseCamera camera;

    this(Camera camera, World world, ICommandManager commandManager) {
        this.world = world;
        this.camera = new PlayerChaseCamera(camera, this);
        this.elasticSphere = new ElasticSphere(this, this.camera);
        this.needleSphere = new NeedleSphere(this);
        this.springSphere = new SpringSphere(this, this.camera);
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
        commandManager.addCommand(new ButtonCommand(() => controller.justPressed(CButton.Decide), &this.onDecisideJustPressed));
        commandManager.addCommand(new StickCommand(() => controller.getLeftStickValue.safeNormalize, &this.onMovePress));
        commandManager.addCommand(new StickCommand(() => controller.getRightStickValue.safeNormalize, &this.onRotatePress));
    }

    void step() {
        this.sphere = this.sphere.move();
        this.camera.step();
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
        this.camera.turn(vec2(v.x,0));
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
        this.camera.reset();
    }

    void onLookOverPress() {
        if (this.camera.isLooking) return;
        this.sphere.requestLookOver();
    }

    void onLookOverJustRelease() {
        this.camera.stopLookOver();
    }

    void onDecisideJustPressed() {
    }

    vec3 getCameraTarget() {
        return this.sphere.getCameraTarget;
    }

    vec3 getLastDirection() {
        return this.sphere.lastDirection();
    }

}
