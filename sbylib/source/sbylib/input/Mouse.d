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
    import sbylib.utils.Array;
    import sbylib.core.Process;

    private alias Callback = void delegate();

    alias HandlerList = Array!(Process);

    private Window window;
    private bool[MouseButton] before;
    private bool[MouseButton] pressed;
    private HandlerList[MouseButton] isPressedCallback;
    private HandlerList[MouseButton] isReleasedCallback;
    private HandlerList[MouseButton] justPressedCallback;
    private HandlerList[MouseButton] justReleasedCallback;
    private vec2 mPos;
    private vec2 mDif;

    this(Window window) {
        this.window = window;
        foreach (button; EnumMembers!MouseButton) {
            this.before[button] = false;
            this.pressed[button] = false;
            this.isPressedCallback[button] = HandlerList(0);
            this.isReleasedCallback[button] = HandlerList(0);
            this.justPressedCallback[button] = HandlerList(0);
            this.justReleasedCallback[button] = HandlerList(0);
        }
        this.mDif = vec2(0);

        import sbylib.core.Core;
        Core().addProcess(&update, "mouse.update");
    }

    private void update() {
        auto before = this.mPos;
        this.mPos = (this.window.mousePos / vec2(this.window.width, this.window.height) * 2 - 1) * vec2(1, -1);
        if (!before.hasNaN)
            this.mDif = mPos - before;
        foreach (button; EnumMembers!MouseButton) {
            this.before[button] = this.pressed[button];
            this.pressed[button] = this.window.isPressed(button);
            import std.algorithm : each;
            if (this.isPressed(button)) this.isPressedCallback[button].each!((cb) { cb.step(); return cb.isAlive; });
            if (this.isReleased(button)) this.isReleasedCallback[button].each!((cb) { cb.step(); return cb.isAlive; });
            if (this.justPressed(button)) this.justPressedCallback[button].each!((cb) { cb.step(); return cb.isAlive; });
            if (this.justReleased(button)) this.justReleasedCallback[button].each!((cb) { cb.step(); return cb.isAlive; });
        }
    }

    vec2 pos() const {
        return this.mPos;
    }

    vec2 dif() const 
        in(!this.mDif.hasNaN)
    {
        return this.mDif;
    }

    private void addIsPressedCallback(MouseButton button, Process cb) {
        this.isPressedCallback[button] ~= cb;
    }

    private void addIsReleasedCallback(MouseButton button, Process cb) {
        this.isReleasedCallback[button] ~= cb;
    }

    private void addJustPressedCallback(MouseButton button, Process cb) {
        this.justPressedCallback[button] ~= cb;
    }

    private void addJustReleasedCallback(MouseButton button, Process cb) {
        this.justReleasedCallback[button] ~= cb;
    }

    struct MouseEvent {
        private void delegate(MouseButton, Process) _add;
        MouseButton button;
        bool value;
        alias value this;

        Process add(Callback cb) {
            auto handler = new Process(cb, "mouse");
            this._add(button, handler);
            return handler;
        }
    }

    MouseEvent isPressed(MouseButton button) {
        return MouseEvent(&addIsPressedCallback, button, this.pressed[button]);
    }

    MouseEvent isReleased(MouseButton button) {
        return MouseEvent(&addIsReleasedCallback, button, !this.pressed[button]);
    }

    MouseEvent justPressed(MouseButton button) {
        return MouseEvent(&addJustPressedCallback, button, !this.before[button] && this.pressed[button]);
    }

    MouseEvent justReleased(MouseButton button) {
        return MouseEvent(&addJustReleasedCallback, button, this.before[button] && !this.pressed[button]);
    }

    bool justPressed() {
        foreach (button; EnumMembers!MouseButton) {
            if (this.justPressed(button)) return true;
        }
        return false;
    }

    bool justReleased() {
        foreach (button; EnumMembers!MouseButton) {
            if (this.justReleased(button)) return true;
        }
        return false;
    }

    MouseButton justPressedButton() {
        foreach (button; EnumMembers!MouseButton) {
            if (this.justPressed(button)) return button;
        }
        assert(false);
    }

    MouseButton justReleasedButton() {
        foreach (button; EnumMembers!MouseButton) {
            if (this.justReleased(button)) return button;
        }
        assert(false);
    }
}
