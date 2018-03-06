module game.tool.manipulator.ManipulatorManager;

import sbylib;
import game.Game;
import game.tool.manipulator;

class ManipulatorManager {

private:
    Manipulator manipulator;
    ViewportMouse mouse;

    CollisionRay ray;

    bool isMoving = false;
    bool isAddedToWorld = false;

public:

    this() {
        this.manipulator = new Manipulator();

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
                auto entity = getCollidedEntity();

                entity.match!(
                    (Entity e) {
                        if (e.getUserData!(Manipulator.Axis).isJust) {
                            this.manipulator.setAxis(e);

                            this.ray.build(this.mouse.getPos(), Game.getWorld3D.getCamera);
                            this.isMoving = this.manipulator.setRay(this.ray);
                        } else {
                            bool isTarget = false; //
                            isTarget |= e.getUserData!string.fmap!(str => str == "crystal").getOrElse(false);

                            if (isTarget) {
                                show();
                            } else {
                                hide();
                            }

                            this.manipulator.setTarget(e);
                            this.isMoving = false;
                        }
                    },
                    () {
                        this.isMoving = false;
                    }
                );
            }
        }

        if (this.mouse.isPressed(MouseButton.Button1) && this.isMoving) {
            this.ray.build(this.mouse.getPos(), Game.getWorld3D.getCamera);
            this.manipulator.updateRay(this.ray);
        } else {
            this.isMoving = false;
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

    void show() {
        if (isAddedToWorld) return;
        Game.getWorld3D.add(this.manipulator.entity);
        isAddedToWorld = true;
    }

    void hide() {
        if (!isAddedToWorld) return;
        Game.getWorld3D.remove(this.manipulator.entity);
        isAddedToWorld = false;
    }


}
