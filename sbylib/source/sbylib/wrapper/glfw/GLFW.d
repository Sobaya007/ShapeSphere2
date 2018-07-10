module sbylib.wrapper.glfw.GLFW;

import derelict.glfw3.glfw3;
import sbylib.utils.Path;

class GLFW {

    private static _terminated = false;

    private this(){}

    public static void init() {
        version (Windows) {
            DerelictGLFW3.load(DllPath("glfw3.dll"));
        } else {
            DerelictGLFW3.load();
        }
        glfwSetErrorCallback(&errorCallback);
        auto initResult = glfwInit();
        assert(initResult,"Failed to initialize GLFW");
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
        import std.stdio : printf;

        printf("error code: %x\n", error);
        printf("description: %s\n", description);
        assert(false, "GLFW error");
    }
}
