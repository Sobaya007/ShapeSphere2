module sbylib.wrapper.glfw.GLFW;

import derelict.glfw3.glfw3;
import sbylib.setting;
import std.stdio;

class GLFW {

    private static _terminated = false;

    private this(){}

    public static void init() {
        DerelictGLFW3.load(GLFW_DLL_PATH);
        glfwSetErrorCallback(&errorCallBack);
        assert(glfwInit(),"Failed to initialize GLFW");
    }

    public static void terminate() {
        glfwTerminate();
        _terminated = true;
    }

    public static hasTerminated() {
        return _terminated;
    }

    private extern(C) void errorCallBack(int error, const(char)* description) nothrow {
        printf("description: %.*s\n", description);
        assert(false, "GLFW error");
    }
}
