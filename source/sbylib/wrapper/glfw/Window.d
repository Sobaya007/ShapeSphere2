module sbylib.wrapper.glfw.Window;

import derelict.glfw3.glfw3;
import derelict.opengl;

import std.string, std.stdio, std.algorithm;
import sbylib.math.Vector;
import sbylib.wrapper.glfw.Constants;
import sbylib.wrapper.gl.Functions;

/*
   GLFW準拠のウインドウのクラスです
 */

private GlfwWindow[GLFWwindow*] windows;

class GlfwWindow {

    alias ResizeCallback = void delegate();
    private {
        GLFWwindow *window;
        uint width, height;
        bool resized;
        string title;
        ResizeCallback[] resizeCallbacks;
        bool[int] hasKeyPressed; // KeyButton -> bool
    }
    public {

        bool shouldClose() {
            return window.glfwWindowShouldClose() > 0;
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

        uint getWidth() const {
            return this.width;
        }

        uint getHeight() const {
            return this.height;
        }

        string getTitle() const {
            return this.title;
        }

        void addResizeCallback(ResizeCallback cb) {
            this.resizeCallbacks ~= cb;
        }

        void removeResizeCallback(ResizeCallback cb) {
            this.resizeCallbacks = this.resizeCallbacks.remove!(r => r is cb);
        }
    }

    package(sbylib) {

        this(string title, int width, int height) {
            this.title = title;
            this.resized = true; // for first resize callback
            glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR,4);
            glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR,3);
            glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
            glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
            glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, 1);
            window = glfwCreateWindow(width, height,title.toStringz, null, null);
            if(!window){
                assert(false, "Failed to create window");
            }

            glfwSetWindowPos(this.window, 200, 200);
            glfwSetWindowSizeCallback(this.window, &resizeCallback);
            glfwMakeContextCurrent(window);

            glfwSetKeyCallback(this.window, &keyCallback);

            this.setTitle(title);

            //Actual window size might differ from given size.
            glfwGetWindowSize(this.window, &width, &height);
            this.width = width;
            this.height = height;

            auto glver = DerelictGL3.reload();
            writeln("Version = ", glver);
            assert(glver > GLVersion.gl33, "OpenGL version is too low");

            windows[this.window] = this;
        }

        bool getKey(KeyButton key) {
            return key in hasKeyPressed && hasKeyPressed[key];
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
            if (!this.resized) return;
            this.resized = false;
            foreach (cb; resizeCallbacks) {
                cb();
            }
        }

        void swapBuffers() {
            window.glfwSwapBuffers();
        }

        void setClipboardString(dstring str) {
            import std.conv;
            window.glfwSetClipboardString(str.to!string.toStringz);
        }

        dstring getClipboardString() {
            import std.conv;
            return window.glfwGetClipboardString().fromStringz.to!dstring;
        }
    }
}

private extern(C) void resizeCallback(GLFWwindow *window, int w, int h) nothrow {
    assert(window in windows);
    windows[window].width = w;
    windows[window].height = h;
    windows[window].resized = true;
}

private extern(C) void keyCallback(GLFWwindow *window, int key, int scancode, int action, int mods) nothrow {
    if (key == GLFW_KEY_UNKNOWN) {
        windows[window].hasKeyPressed[-scancode] = action == GLFW_PRESS;
    } else {
        windows[window].hasKeyPressed[key] = action == GLFW_PRESS;
    }
}
