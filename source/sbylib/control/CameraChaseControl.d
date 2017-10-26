module sbylib.control.CameraChaseControl;
import sbylib.mesh.Object3D;
import sbylib.math.Vector;
import sbylib.camera.Camera;
import sbylib.constant.ConstantManager;
import sbylib.constant.Const;

class CameraChaseControl {

    private Camera camera;
    private vec3 delegate() target;
    private vec3 vel;
    private ConstTemp!float defaultLength, k, c;

    this(Camera camera, vec3 delegate() target) {
        this.camera = camera;
        this.target = target;
        this.defaultLength = ConstantManager.get!float("defaultLength");
        this.k = ConstantManager.get!float("k");
        this.c = ConstantManager.get!float("c");
        this.vel = vec3(0);
    }

    void step() {
        auto t = target();
        auto v = this.camera.getObj().pos - t;
        auto dp = v.length - defaultLength;
        auto dy = v.y;
        v = normalize(v);
        vel -= (k * dp + c * dot(vel, v)) * v;
        vel *= 1 - c;
        auto cobj = this.camera.getObj();
        cobj.pos += vel;
        auto ay = t.y + 3;
        cobj.pos.y = (cobj.pos.y - ay) * 0.9 + ay;
        cobj.lookAt(t);
    }
}
