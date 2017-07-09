module sbylib.input.Mouse;

import sbylib.math.Matrix;
import sbylib.collision.geometry.CollisionRay;
import sbylib.camera.Camera;
import sbylib.utils.Functions;

import std.traits;
public {
    import sbylib.wrapper.glfw.Window;
    import sbylib.math.Vector;
    import sbylib.wrapper.glfw.Constants;
}

class Mouse {

    private vec2 pos;
    private vec2 dif;
    private bool[MouseButton] before;
    private bool[MouseButton] pressed;
    private Window window;

    this(Window window) {
        this.window = window;
        foreach (button; EnumMembers!MouseButton) {
            this.pressed[button] = false;
        }
    }

    void update() {
        auto before = this.pos;
        this.pos = (this.window.getMousePos() / vec2(this.window.getWidth(), this.window.getHeight()) * 2 - 1) * vec2(1, -1);
        this.dif = pos - before;
        foreach (button; EnumMembers!MouseButton) {
            this.before[button] = this.pressed[button];
            this.pressed[button] = this.window.getMouseButton(button);
        }
    }

    vec2 getPos() const {
        return this.pos;
    }

    vec2 getDif() const {
        return this.dif;
    }

    bool isPressed(MouseButton button) const {
        return this.pressed[button];
    }

    bool justPressed(MouseButton button) const {
        return !this.before[button] && this.pressed[button];
    }

    bool justReleased(MouseButton button) const {
        return this.before[button] && !this.pressed[button];
    }

    bool justPressed() const {
        foreach (button; EnumMembers!MouseButton) {
            if (this.justPressed(button)) return true;
        }
        return false;
    }

    bool justReleased() const {
        foreach (button; EnumMembers!MouseButton) {
            if (this.justReleased(button)) return true;
        }
        return false;
    }

    MouseButton justPressedButton() const {
        foreach (button; EnumMembers!MouseButton) {
            if (this.justPressed(button)) return button;
        }
        assert(false);
    }

    MouseButton justReleasedButton() const {
        foreach (button; EnumMembers!MouseButton) {
            if (this.justReleased(button)) return button;
        }
        assert(false);
    }
}
