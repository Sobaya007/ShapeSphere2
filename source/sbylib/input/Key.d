module sbylib.input.Key;

import std.traits;

public {
    import sbylib.core.Window;
    import sbylib.wrapper.glfw.Constants;
}

class Key {
    alias Callback = void delegate();
    private Window window;
    private bool[KeyButton] before;
    private bool[KeyButton] buttons;
    private Callback[][KeyButton] isPressedCallback;
    private Callback[][KeyButton] isReleasedCallback;
    private Callback[][KeyButton] justPressedCallback;
    private Callback[][KeyButton] justReleasedCallback;


    package(sbylib) this(Window window) {
        this.window = window;
        foreach (button; EnumMembers!(KeyButton)) {
            this.before[button] = this.buttons[button] = false;
            this.isPressedCallback[button] = [];
            this.isReleasedCallback[button] = [];
            this.justPressedCallback[button] = [];
            this.justReleasedCallback[button] = [];
        }
    }


    package(sbylib) void update() {
        foreach (button; EnumMembers!(KeyButton)) {
            this.before[button] = this.buttons[button];
            this.buttons[button] = this.window.getKey(button);
            import std.algorithm : each;
            if (this.isPressed(button)) this.isPressedCallback[button].each!(cb => cb());
            if (this.isReleased(button)) this.isReleasedCallback[button].each!(cb => cb());
            if (this.justPressed(button)) this.justPressedCallback[button].each!(cb => cb());
            if (this.justReleased(button)) this.justReleasedCallback[button].each!(cb => cb());
        }
    }

    private void addIsPressedCallback(KeyButton button, Callback cb) {
        this.isPressedCallback[button] ~= cb;
    }

    private void addIsReleasedCallback(KeyButton button, Callback cb) {
        this.isReleasedCallback[button] ~= cb;
    }

    private void addJustPressedCallback(KeyButton button, Callback cb) {
        this.justPressedCallback[button] ~= cb;
    }

    private void addJustReleasedCallback(KeyButton button, Callback cb) {
        this.justReleasedCallback[button] ~= cb;
    }

    struct KeyEvent {
        private void delegate(KeyButton, Callback) _add;
        KeyButton button;
        bool value;
        alias value this;

        void add(Callback cb) {
            this._add(button, cb);
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

    alias opIndex = isPressed;
}
