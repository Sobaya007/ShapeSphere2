module sbylib.control.GuiControl;

import sbylib.wrapper.glfw.Constants;
import sbylib.core.Window;
import sbylib.input.Key;
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
    private Key key;
    private IControllable[MouseButton] colEntry;
    private World world;
    private CollisionRay ray;
    private OrthoCamera camera;
    private IControllable[] controllables;
    private Maybe!IControllable selectedControllable = None!IControllable;

    this(Window window, OrthoCamera camera, World world, Key key) {
        this.ray = new CollisionRay();
        this.mouse = new Mouse2D(window, camera);
        this.world = world;
        this.camera = camera;
        this.key = key;
    }

    void update(Process proc) {
        updateMouse();
        updateKey();
        updateControllables();
    }

    void add(IControllable controllable) {
        this.controllables ~= controllable;
        this.world.add(controllable.getEntity());
    }

private:
    void updateMouse() {
        this.mouse.update();
        if (this.mouse.justPressed()) {
            getCollidedControllable()
                .apply!((IControllable controllable) {
                this.colEntry[this.mouse.justPressedButton()] = controllable;
                controllable.onMousePressed(this.mouse.justPressedButton());
            });
            this.selectedControllable = None!IControllable;
        }
        if (this.mouse.justReleased()) {
            auto mouseButton = this.mouse.justReleasedButton();
            if (mouseButton in this.colEntry && this.colEntry[mouseButton] !is null) {
                getCollidedControllable()
                    .apply!((IControllable controllable) {
                    this.colEntry[mouseButton].onMouseReleased(mouseButton, controllable is this.colEntry[mouseButton]);
                    this.selectedControllable = Just(controllable);
                });
            }

            this.colEntry[mouseButton] = null;
        }
    }

    void updateKey() {
        import std.traits;
        bool shiftPressed = this.key.isPressed(KeyButton.LeftShift) || this.key.isPressed(KeyButton.RightShift);
        bool controlPressed = this.key.isPressed(KeyButton.LeftControl) || this.key.isPressed(KeyButton.RightControl);
        foreach (button; EnumMembers!KeyButton) {
            if (this.key.justPressed(button)) {
                this.selectedControllable.apply!(
                    c => c.onKeyPressed(button, shiftPressed, controlPressed)
                );
            }
            if (this.key.justReleased(button)) {
                this.selectedControllable.apply!(
                    c => c.onKeyReleases(button, shiftPressed, controlPressed)
                );
            }
        }
    }

    void updateControllables() {
        foreach (controllable; this.controllables) {
            controllable.update(this.mouse);
        }
        this.selectedControllable.apply!(
            c => c.activeUpdate(this.mouse)
        );
    }

    Maybe!IControllable getCollidedControllable() {
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
