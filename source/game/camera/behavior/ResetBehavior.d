module game.camera.behavior.ResetBehavior;

public import game.camera.CameraController;
import sbylib;
import game.camera.behavior.ChaseBehavior;

class ResetBehavior : CameraController.Behavior {

    mixin BehaviorPack;

    private vec3 dir;
    private long count;

    mixin DeclareConfig!(float, "RESET_SPEED_RATE", "camera.json");
    mixin DeclareConfig!(float, "CHASE_TARGET_Y", "camera.json");
    mixin DeclareConfig!(long, "RESET_PERIOD_FRAME", "camera.json");

    void initialize() {
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
        auto ay = target.y + CHASE_TARGET_Y;
        camera.pos.y = (camera.pos.y - ay) * RESET_SPEED_RATE + ay;
        camera.lookAt(target);
        if (this.count-- == 0) {
            controller.transit!(ChaseBehavior);
        }
    }

    override void turn(vec2 v) {}
}
