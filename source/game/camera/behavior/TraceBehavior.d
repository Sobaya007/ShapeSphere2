module game.camera.behavior.TraceBehavior;

public import game.camera.CameraController;
import sbylib;
import dconfig;
import game.camera.behavior.ChaseBehavior;

class TraceBehavior : CameraController.Behavior {

    mixin BehaviorPack;

    struct Trail {
        vec3 pos;
        mat3 rot;
    }

    private Spline!(3) posSpline, upSpline, forwardSpline;
    private mat3 rot;
    private float time;

    mixin HandleConfig;
    @config(ConfigPath("camera.json")) {
        float TRACE_INTERVAL_VELOCITY;
        float TRACE_SPEED;
    }

    private void delegate() onFinish;

    void initialize(Trail[] trailList, void delegate() onFinish) {
        this.initializeConfig();

        this.onFinish = onFinish;

        import std.algorithm : map;
        import std.array : array;

        this.posSpline = new Spline!(3)(trailList.map!(t => t.pos).array, TRACE_INTERVAL_VELOCITY);
        this.upSpline = new Spline!(3)(trailList.map!(t => t.rot.column[1]).array, TRACE_INTERVAL_VELOCITY);
        this.forwardSpline = new Spline!(3)(trailList.map!(t => t.rot.column[2]).array, TRACE_INTERVAL_VELOCITY);
        this.time = 0;
    }

    override void step() {

        auto t = this.time / this.posSpline.totalTime;

        if (t > 1) {
            if (onFinish !is null) onFinish();
            onFinish = null;
            return;
        }
        t = t * t * (3 - 2 * t);
        t *= this.posSpline.totalTime;

        this.time += TRACE_SPEED / this.posSpline.getVelocity(t).length;

        this.camera.pos = this.posSpline.getPoint(t);
        auto up = normalize(this.upSpline.getPoint(t));
        auto forward = normalize(this.forwardSpline.getPoint(t));
        auto side = normalize(cross(up, forward));
        this.camera.rot = mat3(side, up, forward);
    }

    override void turn(vec2 v) {}
}
