module game.camera.behavior.FocusBehavior;

public import game.camera.CameraController;
import sbylib;
import game.camera.behavior.ResetBehavior;

class FocusBehavior : CameraController.Behavior {
    mixin BehaviorPack;

    private Object3D obj;
    private vec3 dir;
    private int count;

    void initialize(Object3D obj, vec3 dir) {
        this.obj = obj;
        this.dir = dir;
        this.count = 0;
        this.dir = normalize(player.getCenter - obj.pos);
        this.dir.y = 0.3;
        this.dir = normalize(this.dir);
        this.dir = mat3.axisAngle(vec3(0,1,0), Radian(-40.deg)) * this.dir;
    }

    override void step() {
        target += (obj.pos - target) * 0.1;
        auto arrival = this.obj.pos + this.dir * defaultLength;
        vel = (arrival - camera.getObj.pos) * 0.1;
        auto cobj = camera.getObj();
        cobj.pos += vel;
        cobj.lookAt(target);

        if (count++ > 100) {
            auto reset = controller.transit!(ResetBehavior);
            reset.initialize();
        }
    }

    override void turn(vec2 value) {}
}
