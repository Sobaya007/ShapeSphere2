module game.camera.behavior.LookOverBehavior;

public import game.camera.CameraController;
import sbylib;

class LookOverBehavior : CameraController.Behavior {

    mixin BehaviorPack;

    enum RADIUS = 20;
    private vec3 targetArrival;
    private vec3 target;
    private vec3 center;
    private vec3 dir;

    mixin DeclareConfig!(float, "LOOKOVER_EYE_SPEED_RATE", "camera.json");
    mixin DeclareConfig!(float, "LOOKOVER_TARGET_SPEED_RATE", "camera.json");

    void initialize(vec3 dir) {
        this.dir = dir;
        this.center = player.getCameraTarget();
        this.target = this.center;
        this.targetArrival = this.center + dir * RADIUS;
    }

    override void step() {
        camera.pos += (player.getCameraTarget() - this.dir * 0.01 - camera.pos) * LOOKOVER_EYE_SPEED_RATE;
        this.target += (this.targetArrival - this.target) * LOOKOVER_TARGET_SPEED_RATE;
        camera.lookAt(this.target);
    }

    override void turn(vec2 v) {
        auto xvec = normalize(cross(this.dir, vec3(0,1,0)));
        auto yvec = normalize(cross(this.dir, xvec));
        this.dir += mat3x2(xvec, yvec) * v * 0.03;
        this.dir = normalize(this.dir);
        this.targetArrival = this.center + this.dir * RADIUS;
    }
}
