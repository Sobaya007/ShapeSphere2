module sbylib.control.CameraControl;

import sbylib.wrapper.glfw.Constants;
import sbylib.wrapper.glfw.Window;
import sbylib.input.Mouse;
import sbylib.input.Key;
import sbylib.camera.Camera;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.math.Quaternion;
import sbylib.math.Angle;
import sbylib.collision.CollisionEntry;
import sbylib.collision.geometry.CollisionRay;
import sbylib.utils.Functions;
import sbylib.core;
import std.math;
import std.algorithm;

class CameraControl {

    private Key key;
    private Mouse mouse;
    private CollisionRay ray;
    private Camera camera;
    private float z;
    private bool cameraRotate;

    this(Key key, Mouse mouse, Camera camera) {
        this.ray = new CollisionRay();
        this.key = key;
        this.mouse = mouse;
        this.camera = camera;
        this.z = 10;
        this.cameraRotate = false;
    }

    void update() {
        if (mouse.justPressed(MouseButton.Button1)) {
            this.cameraRotate = true;
            Core().getWindow().setCursorMode(CursorMode.Disabled);
        }
        if (mouse.justPressed(MouseButton.Button2)) {
            this.cameraRotate = false;
            Core().getWindow().setCursorMode(CursorMode.Normal);
        }
        this.translate();
        if (cameraRotate) {
            this.rotate();
        }
    }

    private void translate() {
        enum speed = 0.2;
        if (this.key[KeyButton.KeyW]) {
            this.camera.pos -= this.camera.rot.column[2] * speed;
        }
        if (this.key[KeyButton.KeyS]) {
            this.camera.pos += this.camera.rot.column[2] * speed;
        }
        if (this.key[KeyButton.KeyA]) {
            this.camera.pos -= this.camera.rot.column[0] * speed;
        }
        if (this.key[KeyButton.KeyD]) {
            this.camera.pos += this.camera.rot.column[0] * speed;
        }
        if (this.key[KeyButton.KeyQ]) {
            this.camera.pos -= this.camera.rot.column[1] * speed;
        }
        if (this.key[KeyButton.KeyE]) {
            this.camera.pos += this.camera.rot.column[1] * speed;
        }
    }

    private void rotate() {
        auto dif2 = this.mouse.getDif();
        auto r = dif2.length.rad;
        auto a = safeNormalize(this.camera.rot * vec3(-dif2.y, dif2.x, 0));
        auto rot = mat3.axisAngle(a, r);
        rot *= this.camera.rot;
        auto forward = rot.column[2];
        auto side = normalize(cross(vec3(0,1,0), forward));
        auto up = normalize(cross(forward, side));
        this.camera.rot = mat3(side, up, forward);
    }
}
