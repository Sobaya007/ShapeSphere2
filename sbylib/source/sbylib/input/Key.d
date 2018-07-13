module sbylib.input.Key;

import std.traits;

public {
    import sbylib.core.Window;
    import sbylib.wrapper.glfw.Constants;
}

class Key {
    import sbylib.utils.Array;
    import sbylib.core.Process;

    private alias Callback = void delegate();

    alias HandlerList = Array!(Process);

    private Window window;
    private bool[KeyButton] before;
    private bool[KeyButton] buttons;
    private HandlerList[KeyButton] isPressedCallback;
    private HandlerList[KeyButton] isReleasedCallback;
    private HandlerList[KeyButton] justPressedCallback;
    private HandlerList[KeyButton] justReleasedCallback;
    private bool callbackFlag = true;

    package(sbylib) this(Window window) {
        this.window = window;
        foreach (button; EnumMembers!(KeyButton)) {
            this.before[button] = this.buttons[button] = false;
            this.isPressedCallback[button] = HandlerList(0);
            this.isReleasedCallback[button] = HandlerList(0);
            this.justPressedCallback[button] = HandlerList(0);
            this.justReleasedCallback[button] = HandlerList(0);
        }

        import sbylib.core.Core;
        Core().addProcess(&update, "key.update");
    }


    private void update() {
        foreach (button; EnumMembers!(KeyButton)) {
            this.before[button] = this.buttons[button];
            this.buttons[button] = this.window.isPressed(button);
            if (!this.callbackFlag) continue;
            import std.algorithm : each;
            if (this.isPressed(button)) this.isPressedCallback[button].each!((cb) { cb.step(); return cb.isAlive; });
            if (this.isReleased(button)) this.isReleasedCallback[button].each!((cb) { cb.step(); return cb.isAlive; });
            if (this.justPressed(button)) this.justPressedCallback[button].each!((cb) { cb.step(); return cb.isAlive; });
            if (this.justReleased(button)) this.justReleasedCallback[button].each!((cb) { cb.step(); return cb.isAlive; });
        }
    }

    void preventCallback() {
        this.callbackFlag = false;
    }

    void allowCallback() {
        this.callbackFlag = true;
    }

    private void addIsPressedCallback(KeyButton button, Process cb) {
        this.isPressedCallback[button] ~= cb;
    }

    private void addIsReleasedCallback(KeyButton button, Process cb) {
        this.isReleasedCallback[button] ~= cb;
    }

    private void addJustPressedCallback(KeyButton button, Process cb) {
        this.justPressedCallback[button] ~= cb;
    }

    private void addJustReleasedCallback(KeyButton button, Process cb) {
        this.justReleasedCallback[button] ~= cb;
    }

    struct KeyEvent {
        private void delegate(KeyButton, Process) _add;
        KeyButton button;
        bool value;
        alias value this;

        Process add(Callback cb) {
            auto handler = new Process(cb, "key");
            this._add(button, handler);
            return handler;
        }
    }

    KeyEvent isPressed(KeyButton button) {
        return KeyEvent(&addIsPressedCallback, button, this.buttons[button]);
    }

    KeyEvent isReleased(KeyButton button) {
        return KeyEvent(&addIsReleasedCallback, button, !this.buttons[button]);
    }

    KeyEvent justPressed(KeyButton button) {
        return KeyEvent(&addJustPressedCallback, button, this.buttons[button] && !this.before[button]);
    }

    KeyEvent justReleased(KeyButton button) {
        return KeyEvent(&addJustReleasedCallback, button, !this.buttons[button] && this.before[button]);
    }

    auto justPressedKey() {
        import sbylib.utils.Maybe;
        foreach (key; EnumMembers!(KeyButton)) {
            if (buttons[key] && !before[key]) return Just(key);
        }
        return None!KeyButton;
    }

    alias opIndex = isPressed;
}
