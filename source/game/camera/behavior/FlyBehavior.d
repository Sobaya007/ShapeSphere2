module game.camera.behavior.FlyBehavior;

public import game.camera.CameraController;
import sbylib;
import game.Game;

class FlyBehavior : CameraController.Behavior {
    mixin BehaviorPack;

    private CameraControl control;

    void initialize() {
        target = player.getCameraTarget();
        if (!this.control) this.control = new CameraControl(camera);
    }

    override void step() {
        this.control.update();
        if (Core().justPressed(KeyButton.Escape)) {
            reset(); 
            import game.player.Controller;
            debug Controller().available = true;
        }
    }

    override void turn(vec2 value) {}
}
