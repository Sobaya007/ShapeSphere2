module sbylib.control.BasicControl;

import sbylib.wrapper.glfw.Constants;
import sbylib.wrapper.glfw.Window;
import sbylib.input.ViewportMouse;
import sbylib.camera.Camera;
import sbylib.math.Angle;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.math.Quaternion;
import sbylib.collision.CollisionEntry;
import sbylib.collision.geometry.CollisionRay;
import sbylib.utils.Functions;
import std.algorithm;
import std.array;

class BasicControl {

    import sbylib.entity.Entity;

    enum Mode {None, Translate, Rotate}

    private ViewportMouse mouse;
    private Entity entity;
    private World world;
    private CollisionRay ray;
    private Camera camera;
    private Mode mode;
    private float z;

    this(ViewportMouse mouse, World world, Camera camera) {
        this.ray = new CollisionRay();
        this.mouse = mouse;
        this.world = world;
        this.camera = camera;
        this.mode = Mode.None;
    }

    void update() {
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
        this.ray.build(this.mouse.pos, this.camera);
        auto colInfo = this.world.rayCast(this.ray);
        if (colInfo.isNone) return;
        this.entity = colInfo.unwrap.entity.getRootParent();
        if (this.mouse.justPressed(MouseButton.Button1)) {
            this.mode = Mode.Translate;
            this.z = -(colInfo.unwrap.point - this.camera.pos).dot(this.camera.worldMatrix.column[2].xyz);
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
        auto dif2 = mouse.dif;
        dif2 *= vec2(this.z) / vec2(this.camera.projMatrix[0,0], this.camera.projMatrix[1,1]);
        this.entity.obj.pos += this.camera.worldMatrix.toMatrix3() * vec3(dif2, 0);
    }

    private void rotate() {
        if (this.mouse.justReleased(MouseButton.Button2)) {
            this.mode = Mode.None;
            return;
        }
        auto dif2 = this.mouse.dif;
        if (dif2.length < 0.01) return;
        auto axisV = cross(vec3(dif2.x, dif2.y, 0), vec3(0,0,1));
        auto axisW = (this.camera.worldMatrix.get() * vec4(axisV, 0)).xyz;
        auto rot = mat3.axisAngle(normalize(axisW), length(axisW).rad);
        this.entity.obj.rot = rot * this.entity.obj.rot;
    }
}
