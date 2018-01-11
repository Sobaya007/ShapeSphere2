module game.camera.behavior.ResetBehavior;

public import game.camera.CameraController;
import sbylib;
import game.camera.behavior.ChaseBehavior;

class ResetBehavior : CameraController.Behavior {

    mixin BehaviorPack;

    private vec3 dir;
    private int count;

    void initialize() {
        this.dir = player.getLastDirection;
        this.count = 15;
    }

    override void step() {
        target += (player.getCameraTarget - target) * 0.9;
        auto r = (player.getCameraTarget() - camera.pos).xz.length;
        auto arrival = player.getCameraTarget() - r * dir;
        vel = (arrival - camera.pos) * 0.1;
        vel.y = 0;
        camera.pos += vel;
        auto ay = target.y + 3;
        camera.pos.y = (camera.pos.y - ay) * 0.9 + ay;
        camera.lookAt(target);
        if (this.count-- == 0) {
            controller.transit!(ChaseBehavior);
        }
    }

    override void turn(vec2 v) {}
}
