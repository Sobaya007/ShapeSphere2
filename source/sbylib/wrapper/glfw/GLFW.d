module sbylib.wrapper.glfw.GLFW;

import derelict.glfw3.glfw3;
import sbylib.utils.Path;
import std.stdio;

class GLFW {

    private static _terminated = false;

    private this(){}

    public static void init() {
        version (Windows) {
            DerelictGLFW3.load(DllPath("glfw3.dll"));
        }
        version (OSX) {
            DerelictGLFW3.load();
        }
        glfwSetErrorCallback(&errorCallback);
        assert(glfwInit(),"Failed to initialize GLFW");
    }

    public static void terminate() {
        glfwTerminate();
        _terminated = true;
    }

    public static hasTerminated() {
        return _terminated;
    }

    private extern(C) void errorCallback(int error, const(char)* description) nothrow {
        import sbylib.wrapper.glfw.Constants : ErrorCode;
        printf("error code: %s\n", error);
        printf("description: %s\n", description);
        assert(false, "GLFW error");
    }
}
