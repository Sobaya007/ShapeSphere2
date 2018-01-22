module game.camera.behavior.FocusBehavior;

public import game.camera.CameraController;
import sbylib;
import game.camera.behavior.ResetBehavior;

class FocusBehavior : CameraController.Behavior {
    mixin BehaviorPack;

    private Object3D obj;
    private vec3 dir;

    mixin DeclareConfig!(float, "FOCUS_SPEED_RATE", "camera.json");

    void initialize(Object3D obj, vec3 dir) {
        this.obj = obj;
        this.dir = dir;
        this.dir = normalize(player.getCenter - obj.pos);
        this.dir.y = 0.3;
        this.dir = normalize(this.dir);
        this.dir = mat3.axisAngle(vec3(0,1,0), Radian(-40.deg)) * this.dir;
    }

    override void step() {
        target += (obj.pos - target) * FOCUS_SPEED_RATE;
        auto arrival = this.obj.pos + this.dir * DEFAULT_LENGTH;
        vel = (arrival - camera.pos) * FOCUS_SPEED_RATE;
        camera.pos += vel;
        camera.lookAt(target);
    }

    override void turn(vec2 value) {}
}
