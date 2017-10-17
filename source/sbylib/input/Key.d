module sbylib.input.Key;

import std.traits;

public {
    import sbylib.core.Window;
    import sbylib.wrapper.glfw.Constants;
}

class Key {
    private Window window;
    private bool[KeyButton] before;
    private bool[KeyButton] buttons;

    package(sbylib) this(Window window) {
        this.window = window;
        foreach (button; EnumMembers!(KeyButton)) {
            this.before[button] = this.buttons[button] = false;
        }
    }

    package(sbylib) void update() {
        foreach (button; EnumMembers!(KeyButton)) {
            this.before[button] = this.buttons[button];
            this.buttons[button] = this.window.getKey(button);
        }
    }

    bool isPressed(KeyButton button) {
        return this.buttons[button];
    }

    bool isReleased(KeyButton button) {
        return !this.buttons[button];
    }

    bool justPressed(KeyButton button) {
        return this.buttons[button] && !this.before[button];
    }

    bool justReleased(KeyButton button) {
        return !this.buttons[button] && this.before[button];
    }

    bool opIndex(KeyButton key) {
        return this.isPressed(key);
    }
}
