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
    private bool rotating;
    float speed = 0.2;

    this(Camera camera, Window window) {
        this.ray = new CollisionRay();
        this.camera = camera;
        this.rotating = false;

        window.key.isPressed(KeyButton.KeyW).add({
            this.camera.pos -= this.camera.rot.column[2] * speed;
        });
        window.key.isPressed(KeyButton.KeyS).add({
            this.camera.pos += this.camera.rot.column[2] * speed;
        });
        window.key.isPressed(KeyButton.KeyA).add({
            this.camera.pos -= this.camera.rot.column[0] * speed;
        });
        window.key.isPressed(KeyButton.KeyD).add({
            this.camera.pos += this.camera.rot.column[0] * speed;
        });
        window.key.isPressed(KeyButton.KeyQ).add({
            this.camera.pos -= this.camera.rot.column[1] * speed;
        });
        window.key.isPressed(KeyButton.KeyE).add({
            this.camera.pos += this.camera.rot.column[1] * speed;
        });
        window.mouse.justPressed(MouseButton.Button1).add({
            this.rotating = true;
            window.setCursorMode(CursorMode.Disabled);
        });
        window.mouse.justPressed(MouseButton.Button2).add({
            this.rotating = false;
            window.setCursorMode(CursorMode.Normal);
        });
        camera.addProcess({
            if (rotating) rotate(window.mouse.dif);
        });
    }

    private void rotate(vec2 dif2) {
        auto r = dif2.length.rad;
        auto a = safeNormalize(this.camera.rot * vec3(-dif2.y, dif2.x, 0));
        auto rot = mat3.axisAngle(a, r);
        rot *= this.camera.rot;
        auto forward = rot.column[2];
        auto side = normalize(cross(vec3(0,1,0), forward));
        auto up = normalize(cross(forward, side));
        this.camera.rot = mat3(side, up, forward);
    }

    static auto attach(Camera camera, Window window) {
        auto control = new CameraControl(camera, window);
        
        return control;
    }
}
