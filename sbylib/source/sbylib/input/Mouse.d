module sbylib.input.Mouse;

import sbylib.math.Matrix;
import sbylib.collision.geometry.CollisionRay;
import sbylib.camera.Camera;
import sbylib.utils.Functions;

import std.traits;
public {
    import sbylib.core.Window;
    import sbylib.math.Vector;
    import sbylib.wrapper.glfw.Constants;
}

class Mouse {

    private vec2 mPos;
    private vec2 mDif;
    private bool[MouseButton] before;
    private bool[MouseButton] pressed;
    private Window window;

    this(Window window) {
        this.window = window;
        foreach (button; EnumMembers!MouseButton) {
            this.pressed[button] = false;
        }
        this.mDif = vec2(0);
    }

    package(sbylib) void update() {
        auto before = this.mPos;
        this.mPos = (this.window.mousePos / vec2(this.window.width, this.window.height) * 2 - 1) * vec2(1, -1);
        if (!before.hasNaN)
            this.mDif = mPos - before;
        foreach (button; EnumMembers!MouseButton) {
            this.before[button] = this.pressed[button];
            this.pressed[button] = this.window.isPressed(button);
        }
    }

    vec2 pos() const {
        return this.mPos;
    }

    vec2 dif() const in {
        assert(!this.mDif.hasNaN);
    } body {
        return this.mDif;
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
