module game.camera.behavior.ChaseBehavior;

public import game.camera.CameraController;
import sbylib;
import game.Game;

class ChaseBehavior : CameraController.Behavior {

    mixin BehaviorPack;
    mixin HandleConfig;

    void initialize() {
        this.initializeConfig();
        target = player.getCameraTarget();
    }

    @config(ConfigPath("camera.json")) {
        float CHASE_MAX_LENGTH;
        float CHASE_TARGET_SPEED_RATE;
        float CHASE_TURN_SPEED;
        float CHASE_TURN_RATE;
        float CHASE_RADIUS_RATE;
    }

    private vec2 arrivalXZ = vec2(1,0);
    private float arrivalPhi = 0.3;
    private float arrivalRadius = 1;
    private float radius = 1;
    private CollisionRay ray = new CollisionRay;

    override void step() {
        import std.algorithm : min;
        import std.math, std.typecons;

        auto d = normalize(camera.pos - target);
        auto phi = asin(d.y);
        phi += (arrivalPhi - phi) * CHASE_TURN_RATE;

        auto xz = d.xz;

        target += (player.getCameraTarget - target) * CHASE_TARGET_SPEED_RATE;

        xz += (arrivalXZ - xz) * CHASE_TURN_RATE;
        xz = normalize(xz);

        auto dir = vec3(xz.x*cos(phi), sin(phi), xz.y*cos(phi));
        ray.start = target;
        ray.dir = dir;
        auto colInfo = Game.getMap().mapEntity.rayCast(ray);
        if (colInfo.isJust) {
            auto r = length(colInfo.get().point - target);
            this.arrivalRadius = min(r, CHASE_MAX_LENGTH);
        }
        this.radius += (this.arrivalRadius - this.radius) * CHASE_RADIUS_RATE;
        camera.pos = target + radius * dir;
        camera.lookAt(target);
    }

    override void turn(vec2 value) {
        import std.math;
        auto c = cos(CHASE_TURN_SPEED * value.x);
        auto s = sin(CHASE_TURN_SPEED * value.x);
        arrivalXZ = normalize(mat2(c, -s, s, c) * arrivalXZ);
    }
}
