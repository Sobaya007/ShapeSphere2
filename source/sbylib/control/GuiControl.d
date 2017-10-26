module sbylib.control.GuiControl;

import sbylib.wrapper.glfw.Constants;
import sbylib.core.Window;
import sbylib.input.Mouse2D;
import sbylib.mesh.Object3D;
import sbylib.camera.Camera;
import sbylib.camera.OrthoCamera;
import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.math.Quaternion;
import sbylib.utils.Lazy;
import sbylib.collision.CollisionEntry;
import sbylib.collision.geometry.CollisionRay;
import sbylib.utils.Functions;
import sbylib.core.World;
import sbylib.core.Process;
import sbylib.control.IControllable;

class GuiControl {

    private Mouse2D mouse;
    private IControllable[MouseButton] colEntry;
    private World world;
    private CollisionRay ray;
    private OrthoCamera camera;
    private IControllable[] controllables;

    this(Window window, OrthoCamera camera, World world) {
        this.ray = new CollisionRay();
        this.mouse = new Mouse2D(window, camera);
        this.world = world;
        this.camera = camera;
    }

    void update(Process proc) {
        this.mouse.update();
        if (this.mouse.justPressed()) {
            getCollidedControllable()
                .apply!((IControllable controllable) {
                this.colEntry[this.mouse.justPressedButton()] = controllable;
                controllable.onMousePressed(this.mouse.justPressedButton());
            });
        }
        if (this.mouse.justReleased()) {
            auto mouseButton = this.mouse.justReleasedButton();
            if (mouseButton in this.colEntry && this.colEntry[mouseButton] !is null) {
                getCollidedControllable()
                    .apply!((IControllable controllable) {
                    this.colEntry[mouseButton].onMouseReleased(mouseButton, controllable is this.colEntry[mouseButton]);
                });
            }

            this.colEntry[mouseButton] = null;
        }
        foreach (controllable; this.controllables) {
            controllable.update(this.mouse);
        }
    }

    void add(IControllable controllable) {
        this.controllables ~= controllable;
        this.world.add(controllable.getEntity());
    }

    private Maybe!IControllable getCollidedControllable() {
        import std.algorithm, std.math, std.array;

        Utils.getRay(this.mouse.getPos(), this.camera, this.ray);
        return this.world.rayCast(this.ray).fmap!((CollisionInfoRay colInfo) {
            auto entity = colInfo.entity;
            while(entity.getUserData() is null) {
                entity = entity.getParent;
            }
            return cast(IControllable)entity.getUserData;
        });
    }
}
