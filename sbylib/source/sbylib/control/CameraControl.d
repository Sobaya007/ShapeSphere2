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

    private CollisionRay ray;
    private Camera camera;
    private bool cameraRotate;
    float speed = 0.2;

    this(Camera camera) {
        this.ray = new CollisionRay();
        this.camera = camera;
        this.cameraRotate = false;

        Core().getKey().isPressed(KeyButton.KeyW).add({
            this.camera.pos -= this.camera.rot.column[2] * speed;
        });
        Core().getKey().isPressed(KeyButton.KeyS).add({
            this.camera.pos += this.camera.rot.column[2] * speed;
        });
        Core().getKey().isPressed(KeyButton.KeyA).add({
            this.camera.pos -= this.camera.rot.column[0] * speed;
        });
        Core().getKey().isPressed(KeyButton.KeyD).add({
            this.camera.pos += this.camera.rot.column[0] * speed;
        });
        Core().getKey().isPressed(KeyButton.KeyQ).add({
            this.camera.pos -= this.camera.rot.column[1] * speed;
        });
        Core().getKey().isPressed(KeyButton.KeyE).add({
            this.camera.pos += this.camera.rot.column[1] * speed;
        });
    }

    void update() {
        if (Core().getMouse().justPressed(MouseButton.Button1)) {
            this.cameraRotate = true;
            Core().getWindow().setCursorMode(CursorMode.Disabled);
        }
        if (Core().getMouse().justPressed(MouseButton.Button2)) {
            this.cameraRotate = false;
            Core().getWindow().setCursorMode(CursorMode.Normal);
        }
        if (cameraRotate) {
            this.rotate();
        }
    }

    private void rotate() {
        auto dif2 = Core().getMouse().dif;
        auto r = dif2.length.rad;
        auto a = safeNormalize(this.camera.rot * vec3(-dif2.y, dif2.x, 0));
        auto rot = mat3.axisAngle(a, r);
        rot *= this.camera.rot;
        auto forward = rot.column[2];
        auto side = normalize(cross(vec3(0,1,0), forward));
        auto up = normalize(cross(forward, side));
        this.camera.rot = mat3(side, up, forward);
    }

    static auto attach(Camera camera) {
        auto control = new CameraControl(camera);

        Core().addProcess(&control.update, "control");
        
        return control;
    }
}
