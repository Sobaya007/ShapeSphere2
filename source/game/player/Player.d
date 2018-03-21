module game.player.Player;

import game.command;
import game.player.BaseSphere;
import game.player.ElasticSphere;
import game.player.NeedleSphere;
import game.player.SpringSphere;
import game.player.PlayerMaterial;
import game.player.Controller;
import game.camera.CameraController;
import game.command.CommandManager;
import sbylib;
import std.algorithm, std.array, std.math, std.meta;

class Player : CommandReceiver {

    alias SphereTypes = AliasSeq!(ElasticSphere, NeedleSphere, SpringSphere);

    alias Mat = ConditionalMaterial!(LambertMaterial, PlayerMaterial);
    alias PlayerEntity = TypedEntity!(GeometryN, Mat);

    enum TIME_STEP = 0.02;

    private BaseSphere sphere;
    private BaseSphere[] spheres;
    CameraController camera;
    Entity[] collisionEntities;

    this(Camera camera) {
        this.camera = new CameraController(camera, this);
        static foreach (SphereType; SphereTypes) {
            this.spheres ~= new SphereType(this, this.camera);
        }
        transit!(ElasticSphere);
        this.camera.initialize();
        auto controller = Controller();
        this.addCommand(new ButtonCommand(() => controller.isPressed(CButton.Press), &this.onDownPress));
        this.addCommand(new ButtonCommand(() => controller.justReleased(CButton.Press), &this.onDownJustRelease));
        this.addCommand(new ButtonCommand(() => controller.isPressed(CButton.Needle), &this.onNeedlePress));
        this.addCommand(new ButtonCommand(() => controller.isReleased(CButton.Needle), &this.onNeedleRelease));
        this.addCommand(new ButtonCommand(() => controller.isPressed(CButton.Spring), &this.onSpringPress));
        this.addCommand(new ButtonCommand(() => controller.justReleased(CButton.Spring), &this.onSpringJustRelease));
        this.addCommand(new ButtonCommand(() => controller.justPressed(CButton.CameraReset), &this.onCameraResetJustPress));
        this.addCommand(new ButtonCommand(() => controller.isPressed(CButton.LookOver), &this.onLookOverPress));
        this.addCommand(new ButtonCommand(() => controller.justReleased(CButton.LookOver), &this.onLookOverJustRelease));
        this.addCommand(new ButtonCommand(() => controller.justPressed(CButton.Decide), &this.onDecisideJustPressed));
        this.addCommand(new StickCommand(() => controller.getLeftStickValue.safeNormalize, &this.onMovePress));
        this.addCommand(new StickCommand(() => controller.getRightStickValue.safeNormalize, &this.onRotatePress));
    }

    void step() {
        this.sphere.move();
        this.camera.step();
    }

    SphereType transit(SphereType)() out (res) {
        assert(this.sphere !is null);
    } body {
        return cast(SphereType)(this.sphere = this.spheres.find!(b => b.instanceof!SphereType).front);
    }

    void onDownPress() {
        this.sphere.onDownPress();
    }

    void onDownJustRelease() {
        this.sphere.onDownJustRelease();
    }

    void onMovePress(vec2 v) {
        this.sphere.onMovePress(v);
    }

    void onRotatePress(vec2 v) {
        // なぜかyが死ぬ
        this.camera.turn(vec2(v.x,0));
    }

    void onNeedlePress() {
        this.sphere.onNeedlePress();
    }

    void onNeedleRelease() {
        this.sphere.onNeedleRelease();
    }

    void onSpringPress() {
        this.sphere.onSpringPress();
    }

    void onSpringJustRelease() {
        this.sphere.onSpringJustRelease();
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
        this.sphere.onDecisideJustPressed();
    }

    vec3 getCenter() {
        return this.sphere.getCenter();
    }

    void setCenter(vec3 center) {
        this.sphere.setCenter(center);
        this.camera.pos = center + vec3(1);
    }

    vec3 getCameraTarget() {
        return this.sphere.getCameraTarget;
    }

    vec3 getLastDirection() {
        return this.sphere.lastDirection();
    }

    debug auto collisionCount() {
        return (cast(ElasticSphere)this.spheres.find!(s => s.instanceof!ElasticSphere).front).elasticSphere2.collisionCount;
    }
}
