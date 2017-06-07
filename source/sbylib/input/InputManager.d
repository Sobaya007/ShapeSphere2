module sbylib.input.InputManager;

import derelict.glfw3.glfw3;
import std.conv;
import sbylib.math;
import sbylib.input;
import sbylib.core;

enum MouseButton{
    Button1 = GLFW_MOUSE_BUTTON_1,
    Button2 = GLFW_MOUSE_BUTTON_2,
    Button3 = GLFW_MOUSE_BUTTON_3,
}

mixin({ //========================================= enum KeyButton　の宣言
    string s = "enum KeyButton{";

    //アルファベット
    foreach (char c; 'A'..'Z'+1) {
        s ~= c;
        s ~= " = GLFW_KEY_" ~ c ~ ",";
    }
        //数字
        foreach (int i; 0..10) {
            s ~= "KEY_";
            s ~= to!string(i);
            s ~= " = GLFW_KEY_" ~ to!string(i) ~  ",";
        }
        //その他
        s ~= "Left = GLFW_KEY_LEFT,";
        s ~= "Right = GLFW_KEY_RIGHT,";
        s ~= "Up = GLFW_KEY_UP,";
            s ~= "Down = GLFW_KEY_DOWN,";
            s ~= "Space = GLFW_KEY_SPACE,";
            s ~= "Enter = GLFW_KEY_ENTER,";
            s ~= "Escape = GLFW_KEY_ESCAPE";

            s ~= "}";
            return s;
}());
