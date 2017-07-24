module sbylib.control.CameraControl;

import sbylib.wrapper.glfw.Constants;
import sbylib.wrapper.glfw.Window;
import sbylib.input.Mouse;
import sbylib.input.Key;
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
import std.math;
import std.algorithm;
import std.array;

class CameraControl {

    enum Mode {None, Translate, Rotate}

    private Key key;
    private Mouse mouse;
    private CollisionRay ray;
    private Camera camera;
    private Mode mode;
    private float z;

    this(Key key, Mouse mouse, Camera camera) {
        this.ray = new CollisionRay();
        this.key = key;
        this.mouse = mouse;
        this.camera = camera;
        this.mode = Mode.None;
        this.z = 10;
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
        import std.algorithm;
        if (this.mouse.justPressed(MouseButton.Button1)) {
            this.mode = Mode.Translate;
        }
        if (this.mouse.justPressed(MouseButton.Button2)) {
            this.mode = Mode.Rotate;
        }
        enum speed = 0.2;
        if (this.key.get(KeyButton.KeyW)) {
            this.camera.pos += this.camera.rot.column[1] * speed;
        }
        if (this.key.get(KeyButton.KeyS)) {
            this.camera.pos -= this.camera.rot.column[1] * speed;
        }
        if (this.key.get(KeyButton.KeyA)) {
            this.camera.pos -= this.camera.rot.column[0] * speed;
        }
        if (this.key.get(KeyButton.KeyD)) {
            this.camera.pos += this.camera.rot.column[0] * speed;
        }
        if (this.key.get(KeyButton.KeyQ)) {
            this.camera.pos -= this.camera.rot.column[2] * speed;
        }
        if (this.key.get(KeyButton.KeyE)) {
            this.camera.pos += this.camera.rot.column[2] * speed;
        }
    }

    private void translate() {
        if (this.mouse.justReleased(MouseButton.Button1)) {
            this.mode = Mode.None;
            return;
        }
        auto dif2 = mouse.getDif();
        this.camera.pos -= this.camera.worldMatrix.toMatrix3() * vec3(dif2, 0);
    }

    private void rotate() {
        if (this.mouse.justReleased(MouseButton.Button2)) {
            this.mode = Mode.None;
            return;
        }
        auto dif2 = this.mouse.getDif();
        if (dif2.length < 0.01) return;
        auto rotX = mat3.axisAngle(this.camera.rot.column[0], -dif2.y);
        auto rotY = mat3.axisAngle(this.camera.rot.column[1], dif2.x);
        auto rot = abs(dif2.x) > abs(dif2.y) ? rotY : rotX;
        this.camera.rot = rot * this.camera.rot;
        auto focus = this.camera.pos + this.camera.rot.column[2] * this.z;
        this.camera.pos = focus + mat3.transpose(rot) * (this.camera.pos - focus);
    }
}
