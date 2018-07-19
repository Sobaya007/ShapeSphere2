module game.camera.behavior.FocusBehavior;

public import game.camera.CameraController;
import sbylib;
import dconfig;
import game.camera.behavior.ResetBehavior;

class FocusBehavior : CameraController.Behavior {

    mixin BehaviorPack;
    mixin HandleConfig;

    private Entity obj;
    private vec3 dir;

    @config(ConfigPath("camera.json")) {
        float FOCUS_SPEED_RATE;
        float FOCUS_DEFAULT_LENGTH;
    }

    void initialize(Entity obj, vec3 dir) {
        this.initializeConfig();
        this.obj = obj;
        this.dir = dir;
        this.dir = normalize(player.getCenter - obj.pos);
        this.dir.y = 0.3;
        this.dir = normalize(this.dir);
        this.dir = mat3.axisAngle(vec3(0,1,0), -40.deg) * this.dir;
    }

    override void step() {
        target += (obj.pos - target) * FOCUS_SPEED_RATE;
        auto arrival = this.obj.pos + this.dir * FOCUS_DEFAULT_LENGTH;
        vel = (arrival - camera.pos) * FOCUS_SPEED_RATE;
        camera.pos += vel;
        camera.lookAt(target);
    }

    override void turn(vec2 value) {}
}
