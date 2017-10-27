module sbylib.input.JoyStick;

import sbylib.input, sbylib.setting, sbylib.wrapper.glfw;
import std.stdio, std.conv, std.format, std.range, std.algorithm, std.array;

//常に使用できるなかで一番若いものを取り扱うことにする。
class JoyStick {

    private GlfwJoyStick[GlfwJoyStick.MAX_JOY - GlfwJoyStick.MIN_JOY + 1] sticks;

    package(sbylib) this() {
        foreach (i; 0..sticks.length) {
            sticks[i] = new GlfwJoyStick(GlfwJoyStick.MIN_JOY + i);
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

    bool getButton(int buttonNum) {
        return this.joy.getButton(buttonNum);
    }

    float getAxis(uint axis) {
        return this.joy.getAxis(axis);
    }

    override string toString() {
        return format!"Name = %s\nButton = %s\nAxis = %s"
        (this.getName(),
                iota(this.getButtonNum()).map!(i => this.getButton(i)).array,
                iota(this.getAxisNum()).map!(i => this.getAxis(i)).array);
    }

    private GlfwJoyStick joy() {
        foreach (s; sticks) {
            if (s.canUse) return s;
        }
        return null;
    }
}
