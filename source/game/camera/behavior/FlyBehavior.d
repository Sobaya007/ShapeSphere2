module game.camera.behavior.FlyBehavior;

public import game.camera.CameraController;
import sbylib;
import game.Game;

debug class FlyBehavior : CameraController.Behavior {
    mixin BehaviorPack;

    private CameraControl control;

    void initialize() {
        target = player.getCameraTarget();
        if (!this.control) this.control = new CameraControl(camera);
    }

    override void step() {
        this.control.update();
        if (Core().getKey().justPressed(KeyButton.Escape)) {
            reset(); 
            import game.player.Controller;
            Controller().available = true;
        }
    }

    override void turn(vec2 value) {}
}
