module sbylib.control.BasicControl;

import sbylib.wrapper.glfw.Constants;
import sbylib.wrapper.glfw.Window;
import sbylib.input.Mouse;
import sbylib.mesh.Object3D;
import sbylib.camera.Camera;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.math.Quaternion;
import sbylib.utils.Watcher;
import sbylib.collision.CollisionEntry;
import sbylib.collision.geometry.CollisionRay;
import sbylib.utils.Functions;
import sbylib.core.Leviathan;

class BasicControl {

    enum Mode {None, Translate, Rotate}

    private Mouse mouse;
    private CollisionEntry colEntry;
    private Leviathan cockatrice;
    private CollisionRay ray;
    private Camera camera;
    private Mode mode;
    private float z;

    this(Mouse mouse, Leviathan cockatrice, Camera camera) {
        this.ray = new CollisionRay();
        this.mouse = mouse;
        this.cockatrice = cockatrice;
        this.camera = camera;
        this.mode = Mode.None;
    }

    void update() {
        this.mouse.update();
        final switch(this.mode) {
        case Mode.None:
            this.none();
            break;
        case Mode.Translate:
            this.translate();
            break;
        case Mode.Rotate:
            this.rotate();
            break;
        }
    }

    private void none() {
        Utils.getRay(this.mouse.getPos(), this.camera, this.ray);
        auto colInfo = this.cockatrice.calcCollideRay(this.ray);
        if (!colInfo.collided) return;
        import std.algorithm;
        if (this.mouse.justPressed(MouseButton.Button1)) {
            this.mode = Mode.Translate;
            this.z = -(colInfo.colPoint - this.camera.getObj().pos).dot(this.camera.getObj().worldMatrix.column[2].xyz);
        }
        if (this.mouse.justPressed(MouseButton.Button2)) {
            this.mode = Mode.Rotate;
        }
    }

    private void translate() {
        if (this.mouse.justReleased(MouseButton.Button1)) {
            this.mode = Mode.None;
            return;
        }
        auto dif2 = mouse.getDif();
        dif2 *= vec2(this.z) / vec2(this.camera.projMatrix[0,0], this.camera.projMatrix[1,1]);
        this.colEntry.obj.pos += this.camera.getObj().worldMatrix.toMatrix3() * vec3(dif2, 0);
    }

    private void rotate() {
        if (this.mouse.justReleased(MouseButton.Button2)) {
            this.mode = Mode.None;
            return;
        }
        auto dif2 = this.mouse.getDif();
        if (dif2.length < 0.01) return;
        auto axisV = cross(vec3(dif2.x, dif2.y, 0), vec3(0,0,1));
        auto axisW = (this.camera.getObj().worldMatrix.get() * vec4(axisV, 0)).xyz;
        auto rot = mat3.axisAngle(normalize(axisW), length(axisW));
        this.colEntry.obj.rot = rot * this.colEntry.obj.rot;
    }
}
