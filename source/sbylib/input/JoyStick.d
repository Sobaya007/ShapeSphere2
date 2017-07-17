module sbylib.input.JoyStick;

import derelict.sdl2.sdl;

import sbylib.input, sbylib.setting;
import std.stdio, std.conv;

class JoyStick {

    static void init() {
        // なぜかSDL_Initするとグルグルがでちゃう
        /*
        SDL_Init(SDL_INIT_GAMECONTROLLER);
        SDL_InitSubSystem(SDL_INIT_JOYSTICK);
        auto count = SDL_NumJoysticks();
        writeln("Joy Stick num = " ~ to!string(count));
        */
    }

    enum Axis{LeftX = 0, LeftY = 1, RightX = 3, RightY = 2}
    private SDL_Joystick *stick;

    private this(int index) {
        SDL_JoystickEventState(SDL_ENABLE);
        stick = SDL_JoystickOpen(index);
    }

    ~this() {
        //SDL_JoystickClose(stick);
    }

    package void update() {
        SDL_JoystickUpdate();
    }

    bool getButton(int buttonNum) {
        return SDL_JoystickGetButton(stick, buttonNum) == 1;
    }

    float getAxis(Axis axis) {
        auto result = SDL_JoystickGetAxis(stick, axis);
        return result / 32768.0;
    }
}

class NullJoyStick : JoyStick {

    this() {
        super(0);
    }

    override bool getButton(int buttonNum) {
        return false;
    }

    override float getAxis(Axis axis) {
        return 0;
    }
}
