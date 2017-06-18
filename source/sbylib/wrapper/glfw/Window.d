module sbylib.wrapper.glfw.Window;

import derelict.glfw3.glfw3;
import derelict.opengl;

import std.string, std.stdio;
import sbylib.math.Vector;
import sbylib.wrapper.glfw.Constants;

/*
   GLFW準拠のウインドウのクラスです
 */

class Window {
private:
    GLFWwindow *window;
    uint width, height;
    string title;
public:

    this(string title, int width, int height) {
        this.title = title;
        this.width = width;
        this.height = height;
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR,4);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR,3);
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
        window = glfwCreateWindow(width, height,title.toStringz, null, null);
        if(!window){
            assert(false, "Failed to create window");
        }

        glfwMakeContextCurrent(window);

        this.setTitle(title);
        this.setSize(width, height);

        auto glver = DerelictGL3.reload();
        writeln("Version = ", glver);
        assert(glver > GLVersion.gl33, "OpenGL version is too low");
    }

    bool shouldClose() {
        return window.glfwWindowShouldClose() > 0;
    }

    void swapBuffers() {
        window.glfwSwapBuffers();
    }

    void setSize(int width, int height) {
        this.width = width;
        this.height = height;
        glfwSetWindowSize(window, width, height);
    }

    void setTitle(string title) {
        this.title = title;
        window.glfwSetWindowTitle(title.toStringz);
    }

@property:

    uint getWidth() const {
        return this.width;
    }

    uint getHeight() const {
        return this.height;
    }

    string getTitle() const {
        return this.title;
    }

    bool getKey(KeyButton key) {
        return isPressed(glfwGetKey(this.window, key));
    }

    bool getMouseButton(MouseButton button) {
        return isPressed(glfwGetMouseButton(this.window, button));
    }

    vec2 getMousePos() {
        double x, y;
        glfwGetCursorPos(this.window, &x, &y);
        return vec2(cast(float)x, cast(float)y);
    }

    bool isPressed(int state) {
        final switch(state) {
        case ButtonState.Press:
            return true;
        case ButtonState.Release:
            return false;
        }
    }

    void pollEvents() {
        glfwPollEvents();
    }
}
