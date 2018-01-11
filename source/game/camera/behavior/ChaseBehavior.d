module game.camera.behavior.ChaseBehavior;

public import game.camera.CameraController;
import sbylib;

class ChaseBehavior : CameraController.Behavior {
    mixin BehaviorPack;

    void initialize() {
        target = player.getCameraTarget();
    }

    override void step() {
        target += (player.getCameraTarget - target) * 0.2;
        auto v = camera.getObj().pos - target;
        auto dp = v.length - defaultLength;
        auto dy = v.y;
        v = normalize(v);
        vel -= (k * dp + c * dot(vel, v)) * v;
        vel *= 1 - c;
        auto cobj = camera.getObj();
        cobj.pos += vel;
        auto ay = target.y + 3;
        cobj.pos.y += (ay - cobj.pos.y) * 0.9;
        cobj.lookAt(target);
    }

    override void turn(vec2 value) {
        auto v = this.player.getCameraTarget() - this.camera.getObj().pos;
        auto arrival = normalize(cross(vec3(0,1,0),v)) * TURN_SPEED * value.x;
        auto dif = arrival - vel;
        vel += dif * 0.1;
    }
}
