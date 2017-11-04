module sbylib.wrapper.glfw.JoyStick;

import derelict.glfw3.glfw3;
import std.conv;
import std.format;
import std.range;
import std.array;
import std.algorithm;

class GlfwJoyStick {

    enum MIN_JOY = GLFW_JOYSTICK_1;
    enum MAX_JOY = GLFW_JOYSTICK_LAST;

    private int joy;

    this(int joy) in {
        assert(GLFW_JOYSTICK_1 <= joy && joy <= GLFW_JOYSTICK_LAST);
    } body {
        this.joy = joy;
    }

    bool canUse() {
        return glfwJoystickPresent(this.joy) == GLFW_TRUE;
    }

    string getName() {
        return glfwGetJoystickName(this.joy).to!string;
    }

    uint getButtonNum() {
        int count;
        glfwGetJoystickButtons(this.joy, &count);
        return count;
    }

    uint getAxisNum() {
        int count;
        glfwGetJoystickAxes(this.joy, &count);
        return count;
    }

    bool getButton(int buttonNum) {
        int po;
        return glfwGetJoystickButtons(this.joy, &po)[buttonNum] == GLFW_PRESS;
    }

    float getAxis(uint axis) {
        int po;
        return glfwGetJoystickAxes(this.joy, &po)[axis];
    }

    override string toString() {
        return format!"Name = %s\nButton = %s\nAxis = %s"
        (this.getName(),
                iota(this.getButtonNum()).map!(i => this.getButton(i)).array,
                iota(this.getAxisNum()).map!(i => this.getAxis(i)).array);
    }

}
