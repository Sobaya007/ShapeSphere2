module game.camera.behavior.ChaseBehavior;

public import game.camera.CameraController;
import sbylib;
import game.Game;

class ChaseBehavior : CameraController.Behavior {
    mixin BehaviorPack;

    void initialize() {
        target = player.getCameraTarget();
    }

    mixin DeclareConfig!(float, "CHASE_TARGET_SPEED_RATE", "camera.json");
    mixin DeclareConfig!(float, "CHASE_CAMERA_Y", "camera.json");
    mixin DeclareConfig!(float, "CHASE_MAX_VELOCITY", "camera.json");
    mixin DeclareConfig!(float, "CHASE_TURN_SPEED", "camera.json");
    mixin DeclareConfig!(float, "CHASE_DEFAULT_LENGTH", "camera.json");
    mixin DeclareConfig!(float, "CHASE_K", "camera.json");
    mixin DeclareConfig!(float, "CHASE_C", "camera.json");
    mixin DeclareConfig!(float, "CHASE_ATTENUATION", "camera.json");
    mixin DeclareConfig!(float, "CHASE_PENETRATION_PENALTY", "camera.json");
    mixin DeclareConfig!(float, "CHASE_RESTITUTION_RATE", "camera.json");

    override void step() {
        target += (player.getCameraTarget - target) * CHASE_TARGET_SPEED_RATE;

        auto v = camera.pos - target;
        auto dp = v.length - CHASE_DEFAULT_LENGTH;
        v = normalize(v);
        vel -= (CHASE_K * dp + CHASE_C * dot(vel, v)) * v;


        auto dy = camera.pos.y - (target.y + CHASE_CAMERA_Y);
        vel.y -= CHASE_K * dy + CHASE_C * v.y;


        vel *= CHASE_ATTENUATION;


        auto colInfos = Array!CollisionInfo(0);
        scope (exit) colInfos.destroy();
        Game.getMap().getStageEntity().collide(colInfos, this.entity);
        foreach (colInfo; colInfos) {
            auto n = colInfo.getPushVector(this.entity);
            auto depth = colInfo.getDepth();
            if (depth < 0) continue;
            this.vel += n * depth * CHASE_PENETRATION_PENALTY;
            if (dot(this.vel, n) < 0) {
                this.vel -= n * dot(n, this.vel) * CHASE_RESTITUTION_RATE;
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
        auto dif = normalize(cross(vec3(0,1,0),v)) * CHASE_TURN_SPEED * value.x;
        vel += dif;
    }
}
