
module sbylib.input.Mouse2D;

import sbylib.camera.OrthoCamera;
import sbylib.input.Mouse;
import sbylib.collision.geometry.CollisionRay;
import sbylib.utils.Functions;

class Mouse2D {
    private Mouse mouse;
    private OrthoCamera camera;
    private CollisionRay ray;
    private vec2 pos;
    private vec2 dif;

    this(Window window, OrthoCamera camera) {
        this.mouse = new Mouse(window);
        this.camera = camera;
        this.ray = new CollisionRay;
    }

    void update() {
        this.mouse.update();
        auto before = this.pos;
        this.pos = (mat4.invert(camera.projMatrix * camera.getObj().viewMatrix) * vec4(mouse.getPos(), 0, 1)).xy;
        this.dif = this.pos - before;
    }

    CollisionRay getRay() {
        Utils.getRay(this.mouse.getPos(), this.camera, this.ray);
        return this.ray;
    }

    vec2 getPos() {
        return this.pos;
    }

    vec2 getDif() {
        return this.dif;
    }

    Mouse getMouse() {
        return this.mouse;
    }

    alias getMouse this;
}
