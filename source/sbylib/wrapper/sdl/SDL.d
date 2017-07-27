module sbylib.wrapper.sdl.SDL;

import derelict.sdl2.sdl;
import sbylib.setting;
import std.stdio;
import std.conv;

class SDL {
    private this(){}

    private static bool _terminated = false;
    private static void delegate()[] onTerminate;

    public static void init() {
        DerelictSDL2.load(SDL2_DLL_PATH);
        assert(SDL_Init(SDL_INIT_JOYSTICK) >= 0);
        SDL_JoystickEventState(SDL_ENABLE);
        auto count = SDL_NumJoysticks();
        writeln("Joy Stick num = " ~ to!string(count));
    }

    public static void update() {
        SDL_JoystickUpdate();
    }

    public static void terminate() {
        foreach (f; onTerminate) {
            f();
        }
        import core.thread;
        Thread.sleep(dur!"msecs"(100)); //すぐにSDL止めると死ぬ
        SDL_Quit();
        _terminated = true;
    }

    public static bool hasTerminated() {
        return _terminated;
    }

    public static void addOnTerminate(void delegate() f) {
        onTerminate ~= f;
    }
}
