module sbylib.control.CameraChaseControl;
import sbylib.mesh.Object3D;
import sbylib.math.Vector;
import sbylib.camera.Camera;
import sbylib.constant.ConstantManager;
import sbylib.constant.Const;

class CameraChaseControl {

    private Camera camera;
    private Object3D target;
    private vec3 vel;
    private ConstTemp!float defaultLength, k, c;

    this(Camera camera, Object3D target) {
        this.camera = camera;
        this.target = target;
        this.defaultLength = ConstantManager.get!float("defaultLength");
        this.k = ConstantManager.get!float("k");
        this.c = ConstantManager.get!float("c");
        this.vel = vec3(0);
    }

    void step() {
        auto v = this.camera.getObj().pos - this.target.pos;
        auto dp = v.length - defaultLength;
        auto dy = v.y;
        v = normalize(v);
        vel -= (k * dp + c * dot(vel, v)) * v;
        vel *= 1 - c;
        this.camera.getObj().pos += vel;
        this.camera.getObj().pos.y = 3;
        this.camera.getObj().lookAt(this.target.pos);
    }
}
