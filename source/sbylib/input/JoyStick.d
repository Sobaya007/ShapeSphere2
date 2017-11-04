module sbylib.input.JoyStick;

import sbylib.input, sbylib.wrapper.glfw;
import std.stdio, std.conv, std.format, std.range, std.algorithm, std.array, std.traits;

//常に使用できるなかで一番若いものを取り扱うことにする。

enum JoyButton {
    A = 1,
    B = 2,
    X = 3,
    Y = 0,
    L1 = 4,
    R1 = 5,
    L2 = 6,
    R2 = 7,
    L3 = 10,
    R3 = 11,
    Select = 8,
    Start = 9,
    Left = 15,
    Right = 13,
    Up = 12,
    Down = 14,
}

enum JoyAxis {
    LeftX = 0,
    LeftY = 1,
    RightX = 2,
    RightY = 3,
}
class JoyStick {

    private GlfwJoyStick[GlfwJoyStick.MAX_JOY - GlfwJoyStick.MIN_JOY + 1] sticks;

    private bool[JoyButton] before;
    private bool[JoyButton] buttons;

    package(sbylib) this() {
        foreach (i; 0..sticks.length) {
            sticks[i] = new GlfwJoyStick(GlfwJoyStick.MIN_JOY + i);
        }
        foreach (button; EnumMembers!(JoyButton)) {
            this.before[button] = this.buttons[button] = false;
        }
    }

    package(sbylib) void update() {
        if (!this.canUse) return;
        foreach (button; EnumMembers!(JoyButton)) {
            this.before[button] = this.buttons[button];
            this.buttons[button] = this.joy.getButton(button);
        }
    }

    bool canUse() {
        return this.joy !is null;
    }

    string getName() {
        return this.joy.getName;
    }

    uint getButtonNum() {
        return this.joy.getButtonNum;
    }

    uint getAxisNum() {
        return this.joy.getAxisNum;
    }

    bool isPressed(JoyButton b) {
        return this.buttons[b];
    }

    bool isReleased(JoyButton b) {
        return !this.buttons[b];
    }

    bool justPressed(JoyButton b) {
        return this.buttons[b] && !this.before[b];
    }

    bool justReleased(JoyButton b) {
        return !this.buttons[b] && this.before[b];
    }

    float getAxis(JoyAxis a) {
        return this.joy.getAxis(a);
    }

    override string toString() {
        return format!"Name = %s\nButton:\n %s\nAxis = %s"
        (this.getName(),
                [EnumMembers!JoyButton].map!(button => button.to!string ~ "  " ~ this.buttons[button].to!string).join("\n"),
                [EnumMembers!JoyAxis].map!(axis => axis.to!string ~ "  " ~ this.getAxis(axis).to!string).join("\n"));
    }

    private GlfwJoyStick joy() {
        foreach (s; sticks) {
            if (s.canUse) return s;
        }
        return null;
    }
}
