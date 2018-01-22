module sbylib.wrapper.glfw.Window;

import derelict.glfw3.glfw3;
import derelict.opengl;

import std.string, std.stdio, std.algorithm;
import sbylib.math.Vector;
import sbylib.wrapper.glfw.Constants;
import sbylib.wrapper.gl.Functions;
import sbylib.wrapper.gl.GL;

/*
   GLFW準拠のウインドウのクラスです
 */

private GlfwWindow[GLFWwindow*] windows;

class GlfwWindow {

    alias ResizeCallback = void delegate();
    private {
        GLFWwindow *window;
        int width, height;
        bool resized;
        bool isFullScreen;
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

        void toggleFullScreen() {
            this.isFullScreen = !this.isFullScreen;
            auto newWindow = glfwCreateWindow(width, height,title.toStringz, this.isFullScreen ? glfwGetPrimaryMonitor() : null, this.window);
            this.destroy();
            this.setWindow(newWindow);
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

        void setCursorPos(double xpos, double ypos) {
            glfwSetCursorPos(this.window, xpos, ypos);
        }

        void setCursorMode(CursorMode mode) {
            glfwSetInputMode(this.window, GLFW_CURSOR, mode);
        }
    }

    package(sbylib) {

        this(string title, int width, int height) {
            this.title = title;
            this.resized = true; // for first resize callback
            glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR,4);
            glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR,1);
            glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
            glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
            glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, 1);
            auto window = glfwCreateWindow(width, height,title.toStringz, null, null);
            if(!window){
                assert(false, "Failed to create window");
            }

            this.setWindow(window);

            glfwSetWindowPos(window, 200, 200);

            GL.glVersion = DerelictGL3.reload();
            writeln("Version = ", GL.glVersion);
            assert(GL.glVersion > GLVersion.gl30, "OpenGL version is too low");
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

    private void destroy() {
        glfwDestroyWindow(this.window);
        windows.remove(this.window);
    }

    private void setWindow(GLFWwindow *window) {
        this.window = window;
        glfwSetWindowSizeCallback(this.window, &resizeCallback);
        glfwMakeContextCurrent(this.window);

        glfwSetKeyCallback(this.window, &keyCallback);

        this.setTitle(title);

        //Actual window size might differ from given size.
        glfwGetWindowSize(this.window, &width, &height);
        this.width = width;
        this.height = height;

        windows[this.window] = this;
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
        windows[window].hasKeyPressed[-scancode] = action == GLFW_PRESS || action == GLFW_REPEAT;
    } else {
        windows[window].hasKeyPressed[key] = action == GLFW_PRESS || action == GLFW_REPEAT;
    }
}
