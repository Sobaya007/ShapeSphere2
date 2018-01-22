module game.camera.behavior.ChaseBehavior;

public import game.camera.CameraController;
import sbylib;
import game.Game;

class ChaseBehavior : CameraController.Behavior {
    mixin BehaviorPack;

    void initialize() {
        target = player.getCameraTarget();
    }

    mixin DeclareConfig!(float, "CHASE_SPEED_RATE", "camera.json");
    mixin DeclareConfig!(float, "CHASE_TARGET_Y", "camera.json");
    mixin DeclareConfig!(float, "CHASE_MAX_VELOCITY", "camera.json");
    mixin DeclareConfig!(float, "CHASE_TURN_SPEED", "camera.json");

    override void step() {
        target += (player.getCameraTarget - target) * CHASE_SPEED_RATE;

        auto v = camera.pos - target;
        auto dp = v.length - DEFAULT_LENGTH;
        v = normalize(v);
        vel -= (K * dp + C * dot(vel, v)) * v;
        auto ay = target.y + CHASE_TARGET_Y;
        vel.y += (ay - camera.pos.y) * CHASE_SPEED_RATE;
        vel *= 1 - C;
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
        if (vel.length > CHASE_MAX_VELOCITY) {
            vel = CHASE_MAX_VELOCITY * vel.safeNormalize;
        }
        camera.pos += vel;

        camera.lookAt(target);
    }

    override void turn(vec2 value) {
        auto v = this.player.getCameraTarget() - this.camera.pos;
        auto arrival = normalize(cross(vec3(0,1,0),v)) * CHASE_TURN_SPEED * value.x;
        auto dif = arrival - vel;
        vel += dif * CHASE_TURN_SPEED;
    }
}
