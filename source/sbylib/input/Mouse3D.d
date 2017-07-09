module sbylib.input.Mouse3D;

import sbylib.camera.Camera;
import sbylib.input.Mouse;
import sbylib.collision.geometry.CollisionRay;
import sbylib.utils.Functions;

class Mouse3D {
    private Mouse mouse;
    private Camera camera;
    private CollisionRay ray;
    vec2 pos;

    this(Window window, Camera camera) {
        this.mouse = new Mouse(window);
        this.camera = camera;
        this.ray = new CollisionRay;
    }

    void update() {
        this.mouse.update();
        vec2 pos;
    }

    CollisionRay getRay() {
        Utils.getRay(this.mouse.getPos(), this.camera, this.ray);
        return this.ray;
    }
}
