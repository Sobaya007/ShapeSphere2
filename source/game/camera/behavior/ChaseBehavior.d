module game.camera.behavior.ChaseBehavior;

public import game.camera.CameraController;
import sbylib;
import game.Game;

class ChaseBehavior : CameraController.Behavior {
    mixin BehaviorPack;

    void initialize() {
        target = player.getCameraTarget();
    }

    mixin DeclareConfig!(float, "CHASE_MAX_LENGTH", "camera.json");
    mixin DeclareConfig!(float, "CHASE_TARGET_SPEED_RATE", "camera.json");
    mixin DeclareConfig!(float, "CHASE_TURN_SPEED", "camera.json");
    mixin DeclareConfig!(float, "CHASE_TURN_RATE", "camera.json");
    mixin DeclareConfig!(float, "CHASE_RADIUS_RATE", "camera.json");

    private float arrivalTheta = 0;
    private float theta = 0;
    private float phi = 0.3;
    private float radius = 1;
    private CollisionRay ray = new CollisionRay;

    override void step() {
        import std.algorithm : min;
        import std.math, std.typecons;

        target += (player.getCameraTarget - target) * CHASE_TARGET_SPEED_RATE;

        theta += (arrivalTheta - theta) * CHASE_TURN_RATE;

        auto dir = vec3(cos(theta)*cos(phi), sin(phi), sin(theta)*cos(phi));
        ray.start = target;
        ray.dir = dir;
        auto colInfo = Game.getMap().getStageEntity.rayCast(ray);
        if (colInfo.isJust) {
            auto r = length(colInfo.get().point - target);
            r = min(r, CHASE_MAX_LENGTH);
            this.radius += (r - this.radius) * CHASE_RADIUS_RATE;
            camera.pos = target + radius * dir;
        }
        camera.lookAt(target);
    }

    override void turn(vec2 value) {
        arrivalTheta += value.x * CHASE_TURN_SPEED;
    }
}
