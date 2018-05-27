module game.camera.behavior.ResetBehavior;

public import game.camera.CameraController;
import sbylib;
import game.camera.behavior.ChaseBehavior;

class ResetBehavior : CameraController.Behavior {

    mixin BehaviorPack;
    mixin HandleConfig;

    private vec3 dir;
    private long count;

    @config(ConfigPath("camera.json")) {
        float RESET_SPEED_RATE;
        float CHASE_CAMERA_Y;
        long RESET_PERIOD_FRAME;
    }

    void initialize() {
        this.initializeConfig();
        this.dir = player.getLastDirection;
        this.count = RESET_PERIOD_FRAME;
    }

    override void step() {
        target += (player.getCameraTarget - target) * RESET_SPEED_RATE;
        auto r = (player.getCameraTarget() - camera.pos).xz.length;
        auto arrival = player.getCameraTarget() - r * dir;
        vel = (arrival - camera.pos) * 0.1;
        vel.y = 0;
        camera.pos += vel;
        auto ay = target.y + CHASE_CAMERA_Y;
        camera.pos.y = (camera.pos.y - ay) * RESET_SPEED_RATE + ay;
        camera.lookAt(target);
        if (this.count-- == 0) {
            controller.transit!(ChaseBehavior);
        }
    }

    override void turn(vec2 v) {}
}
