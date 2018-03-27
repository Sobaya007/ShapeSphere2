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
                        if (isAxis(e)) {
                            this.manipulator.setAxis(e);

                            this.ray.build(this.mouse.getPos(), Game.getWorld3D.getCamera);
                            this.isMoving = this.manipulator.setRay(this.ray);
                        } else {
                            if (isTarget(e)) {
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
            Entity e = colInfo.entity;
            while(e.getParent.isJust) {
                if (isTarget(e)) break;
                if (isAxis(e)) break;
                e = e.getParent.get;
            }
            return e;
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

private:
    bool isTarget(Entity entity) {
        return entity.getUserData!ManipulatorTarget.isJust;
    }

    bool isAxis(Entity entity) {
        return entity.getUserData!(Manipulator.Axis).isJust;
    }


}
