module game.tool.manipulator.ManipulatorManager;

import sbylib;
import game.Game;
import game.tool.manipulator;

class ManipulatorManager {

private:
    Manipulator manipulator;
    ViewportMouse mouse;

    CollisionRay ray;
    Maybe!Entity selectedEntity;

public:

    this() {
        this.manipulator = new Manipulator();
        Game.getWorld3D.add(this.manipulator.entity);

        this.mouse = new ViewportMouse(Game.getScene.viewport);
        this.ray = new CollisionRay();
    }

    void update() {
        updateMouse();
    }

private:
    void updateMouse() {
        if (this.mouse.justPressed()) {
            auto mouseButton = this.mouse.justPressedButton();
            if (mouseButton == MouseButton.Button1) {
                this.selectedEntity = getCollidedEntity();

                this.selectedEntity.apply!(a => this.manipulator.setTarget(a));
            }
        }
        if (this.mouse.justReleased()) {
            auto mouseButton = this.mouse.justReleasedButton();
            if (mouseButton == MouseButton.Button1) {

            }
        }
    }

    Maybe!Entity getCollidedEntity() {
        import std.stdio;
        import std.algorithm, std.math, std.array;
        this.ray.build(this.mouse.getPos(), Game.getWorld3D.getCamera);

        return Game.getWorld3D.rayCast(this.ray).fmap!((CollisionInfoRay colInfo) {
            return colInfo.entity;//.getRootParent;
        });
    }


}
