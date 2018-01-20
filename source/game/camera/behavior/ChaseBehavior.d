module game.camera.behavior.ChaseBehavior;

public import game.camera.CameraController;
import sbylib;
import game.Game;

class ChaseBehavior : CameraController.Behavior {
    mixin BehaviorPack;

    void initialize() {
        target = player.getCameraTarget();
    }

    override void step() {
        target += (player.getCameraTarget - target) * 0.2;

        auto v = camera.pos - target;
        auto dp = v.length - defaultLength;
        v = normalize(v);
        vel -= (k * dp + c * dot(vel, v)) * v;
        auto ay = target.y + 3;
        vel.y += (ay - camera.pos.y) * 0.2;
        vel *= 1 - c;
        auto colInfos = Array!CollisionInfo(0);
        scope (exit) colInfos.destroy();
        Game.getMap().getPolygon().collide(colInfos, this.entity);
        foreach (colInfo; colInfos) {
            auto n = colInfo.getPushVector(this.entity);
            auto depth = colInfo.getDepth();
            if (depth < 0) continue;
            if (dot(this.vel, n) < 0) {
                this.vel -= n * dot(n, this.vel) * 1;
            }
        }
        if (vel.length > 0.5) {
            vel = 0.5 * vel.safeNormalize;
        }
        camera.pos += vel;

        camera.lookAt(target);
    }

    override void turn(vec2 value) {
        auto v = this.player.getCameraTarget() - this.camera.pos;
        auto arrival = normalize(cross(vec3(0,1,0),v)) * TURN_SPEED * value.x;
        auto dif = arrival - vel;
        vel += dif * 0.1;
    }
}
