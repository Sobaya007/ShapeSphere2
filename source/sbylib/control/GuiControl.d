module sbylib.control.GuiControl;

import sbylib.wrapper.glfw.Constants;
import sbylib.core.Window;
import sbylib.input.Key;
import sbylib.input.ViewportMouse;
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
import sbylib.render.Viewport;

class GuiControl {

    private ViewportMouse mouse;
    private Key key;
    private Maybe!IControllable[MouseButton] colEntry;
    private World world;
    private CollisionRay ray;
    private OrthoCamera camera;
    private IControllable[] controllables;
    private Maybe!IControllable selectedControllable = None!IControllable;

    private Maybe!KeyButton lastPressedKeyButton = None!KeyButton;
    private int lastPressedKeyCount = 0;

    this(Window window, OrthoCamera camera, IViewport viewport, World world, Key key) {
        this.ray = new CollisionRay();
        this.mouse = new ViewportMouse(viewport);
        this.world = world;
        this.camera = camera;
        this.key = key;

        import std.traits;
        foreach (button; EnumMembers!MouseButton) {
            colEntry[button] = None!IControllable;
        }
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
        if (this.mouse.justPressed()) {
            getCollidedControllable().apply!((IControllable controllable) {
                this.colEntry[this.mouse.justPressedButton()] = Just(controllable);
                controllable.onMousePressed(this.mouse.justPressedButton());
            });
            this.selectedControllable = None!IControllable;
        }
        if (this.mouse.justReleased()) {
            auto mouseButton = this.mouse.justReleasedButton();
            getCollidedControllable().apply!((IControllable a) {
                this.colEntry[mouseButton].apply!((IControllable b) {
                    b.onMouseReleased(mouseButton, a is b);
                });
                this.selectedControllable = Just(a);
            });

            this.colEntry[mouseButton] = None!IControllable;
        }
    }

    void updateKey() {
        import std.traits;
        bool shiftPressed = this.key.isPressed(KeyButton.LeftShift) || this.key.isPressed(KeyButton.RightShift);
        bool controlPressed = this.key.isPressed(KeyButton.LeftControl) || this.key.isPressed(KeyButton.RightControl);
        foreach (button; EnumMembers!KeyButton) {
            if (this.key.justPressed(button)) {
                refreshLastPressedKey(button);
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
        this.lastPressedKeyButton.apply!(
            (button) {
                if (this.key.isPressed(button)) {
                    this.lastPressedKeyCount++;
                } else {
                    clearLastPressedKey();
                }
            }
        );
        this.lastPressedKeyButton.apply!(
            (button) {
                if (hasJustPressed()) {
                    this.selectedControllable.apply!(
                        c => c.onKeyPressed(button, shiftPressed, controlPressed)
                    );
                }
            }
        );
    }

    void updateControllables() {
        foreach (controllable; this.controllables) {
            bool isActive = this.selectedControllable.isJust && cast(void *)this.selectedControllable.get == cast(void *)controllable;
            controllable.update(
                this.mouse,
                this.selectedControllable
            );
        }
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

    private void refreshLastPressedKey(KeyButton key) {
        this.lastPressedKeyButton = Just(key);
        this.lastPressedKeyCount = 0;
    }

    private void clearLastPressedKey() {
        this.lastPressedKeyButton = None!KeyButton;
        this.lastPressedKeyCount = 0;
    }

    // Keyを長押ししているときにjustKeyPressedをtrueにするか？
    private bool hasJustPressed() {
        int minimum = 30;
        int duration = 5;
        int count = this.lastPressedKeyCount;
        return count >= minimum && count%duration == 0;
    }
}
