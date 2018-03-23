module game.camera.behavior.TraceBehavior;

public import game.camera.CameraController;
import sbylib;
import game.camera.behavior.ChaseBehavior;

class TraceBehavior : CameraController.Behavior {

    mixin BehaviorPack;

    struct Trail {
        vec3 pos;
        mat3 rot;
    }

    private Spline!(3) spline;
    private mat3 rot;
    private float time;

    mixin DeclareConfig!(float, "TRACE_INTERVAL_VELOCITY", "camera.json");
    mixin DeclareConfig!(float, "TRACE_SPEED", "camera.json");

    void initialize(Trail[] trailList) {
        import std.algorithm : map;
        import std.array : array;

        this.spline = new Spline!(3)(trailList.map!(t => t.pos).array, TRACE_INTERVAL_VELOCITY);
        this.rot = trailList[0].rot;
        this.time = 0;
    }

    override void step() {
        this.time += TRACE_SPEED / this.spline.getVelocity(this.time).length;
        this.camera.pos = this.spline.getPoint(this.time);
        this.camera.rot = this.rot;
    }

    override void turn(vec2 v) {}
}
