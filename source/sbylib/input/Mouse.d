module sbylib.input.Mouse;

import sbylib.math.Vector;
import sbylib.wrapper.glfw.Constants;
import sbylib.wrapper.glfw.Window;

import std.traits;

class Mouse {

    private vec2 pos;
    private vec2 dif;
    private bool[MouseButton] pressed;

    this() {
    }

    void update(Window window) {
        auto before = this.pos;
        this.pos = window.getMousePos();
        this.dif = pos - before;
        foreach (button; EnumMembers!MouseButton) {
            this.pressed[button] = window.getMouseButton(button);
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
}
