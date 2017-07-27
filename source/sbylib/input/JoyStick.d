module sbylib.input.JoyStick;

import derelict.sdl2.sdl;

import sbylib.input, sbylib.setting, sbylib.wrapper.sdl.SDL;
import std.stdio, std.conv, std.format, std.range, std.algorithm, std.array;

class JoyStick {

    private SDL_Joystick *stick;

    static bool canUse(uint index) {
        return index < SDL_NumJoysticks();
    }

    this(uint index) in {
        assert(canUse(index));
    } body {
        SDL_JoystickEventState(SDL_ENABLE);
        this.stick = SDL_JoystickOpen(index);
        SDL.addOnTerminate(&this.close);
    }

    private void close() {
        SDL_JoystickClose(this.stick);
    }

    package void update() {
        SDL_JoystickUpdate();
    }

    string getName() {
        return SDL_JoystickName(this.stick).to!string;
    }

    uint getButtonNum() {
        return SDL_JoystickNumButtons(this.stick);
    }

    uint getAxisNum() {
        return SDL_JoystickNumAxes(this.stick);
    }

    bool getButton(int buttonNum) {
        return SDL_JoystickGetButton(this.stick, buttonNum) == 1;
    }

    float getAxis(uint axis) {
        auto result = SDL_JoystickGetAxis(this.stick, axis);
        return result / 32768.0;
    }

    override string toString() {
        return format!"Name = %s\nButton = %s\nAxis = %s"
        (this.getName(),
                iota(this.getButtonNum()).map!(i => this.getButton(i)).array,
                iota(this.getAxisNum()).map!(i => this.getAxis(i)).array);
    }
}
