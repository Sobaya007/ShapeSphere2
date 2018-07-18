module sbylib.wrapper.glfw.Window;

import derelict.glfw3.glfw3;
import derelict.opengl;

/*
   GLFW準拠のウインドウのクラスです
 */

private GlfwWindow[GLFWwindow*] windows;

class GlfwWindow {
    
    import sbylib.wrapper.glfw.Constants;
    import sbylib.math.Vector;

    alias ResizeCallback = void delegate();
    private {
        GLFWwindow *window;
        int mWidth, mHeight;
        int windowedX, windowedY;
        int windowedWidth, windowedHeight;
        bool resized;
        bool isFullScreen;
        string mTitle;
        ResizeCallback[] resizeCallbacks;
        bool[int] hasKeyPressed; // KeyButton -> bool
    }
    public {

        static GlfwWindow getCurrentWindow() {
            auto window = glfwGetCurrentContext();
            return windows[window];
        }

        bool shouldClose() {
            return window.glfwWindowShouldClose() > 0;
        }

        void setSize(int mWidth, int mHeight) {
            this.windowedWidth = mWidth;
            this.windowedHeight = mHeight;
            glfwSetWindowSize(window, mWidth, mHeight);
        }

        void setTitle(string mTitle) {
            import std.string : toStringz;

            this.mTitle = mTitle;
            window.glfwSetWindowTitle(mTitle.toStringz);
        }

        void toggleFullScreen() {
            this.toggleFullScreen(glfwGetPrimaryMonitor());
        }

        void toggleFullScreen(int i) {
            int cnt;
            auto monitors = glfwGetMonitors(&cnt);
            i %= cnt;
            this.toggleFullScreen(monitors[i]);
        }

        void toggleFullScreen(GLFWmonitor *monitor) {
            this.isFullScreen = !this.isFullScreen;
            if (this.isFullScreen) {
                auto mode = glfwGetVideoMode(monitor);
                glfwSetWindowMonitor(this.window, monitor, 0, 0, mode.width, mode.height, 0);
            } else {
                glfwSetWindowMonitor(this.window, null,  this.windowedX, this.windowedY, this.windowedWidth, this.windowedHeight, 60);
            }
        }

        int width() const {
            return this.mWidth;
        }

        int height() const {
            return this.mHeight;
        }

        vec2i size() const {
            return vec2i(this.mWidth, this.mHeight);
        }

        vec2i size(vec2i s) {
            glfwSetWindowSize(this.window, s.x, s.y);
            glfwGetWindowSize(this.window, &mWidth, &mHeight);
            return s;
        }

        vec2i pos(vec2i p) {
            glfwSetWindowPos(this.window, p.x, p.y);
            return p;
        }

        vec2i pos() {
            int x, y;
            glfwGetWindowPos(this.window, &x, &y);
            return vec2i(x, y);
        }

        string title() const {
            return this.mTitle;
        }

        void makeCurrent() {
            glfwMakeContextCurrent(this.window);
        }

        void addResizeCallback(ResizeCallback cb) {
            this.resizeCallbacks ~= cb;
        }

        void removeResizeCallback(ResizeCallback cb) {
            import std.algorithm : remove;
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

        this(string mTitle, int mWidth, int mHeight) {
            import std.string : toStringz;
            import std.stdio : writeln;
            import derelict.opengl;
            import sbylib.wrapper.gl.GL;

            this.mTitle = mTitle;
            this.resized = true; // for first resize callback
            glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR,4);
            glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR,1);
            glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
            glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
            glfwWindowHint(GLFW_OPENGL_DEBUG_CONTEXT, 1);

            auto window = glfwCreateWindow(mWidth, mHeight,mTitle.toStringz, null, null);
            if(!window){
                assert(false, "Failed to create window");
            }

            this.setWindow(window);

            GL.glVersion = DerelictGL3.reload();
            writeln("Version = ", GL.glVersion);
            assert(GL.glVersion > GLVersion.gl30, "OpenGL version is too low");
        }

        bool isPressed(KeyButton key) {
            return key in hasKeyPressed && hasKeyPressed[key];
        }

        bool isPressed(MouseButton button) {
            return isPressed(glfwGetMouseButton(this.window, button));
        }

        vec2 mousePos() {
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
            import std.conv : to;
            import std.string : toStringz;
            window.glfwSetClipboardString(str.to!string.toStringz);
        }

        dstring getClipboardString() {
            import std.conv : to;
            import std.string : fromStringz;
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
        glfwSetWindowPosCallback(this.window, &windowPosCallback);
        this.makeCurrent();

        glfwSwapInterval(1);

        glfwSetKeyCallback(this.window, &keyCallback);

        this.setTitle(mTitle);

        //Actual window size might differ from given size.
        glfwGetWindowSize(this.window, &this.windowedWidth, &this.windowedHeight);
        glfwGetWindowSize(this.window, &this.mWidth, &this.mHeight);
        glfwGetWindowPos(this.window, &this.windowedX, &this.windowedY);

        windows[this.window] = this;
    }
}

private extern(C) void windowPosCallback(GLFWwindow *window, int x, int y) nothrow 
    in(window in windows)
{
    if (!windows[window].isFullScreen) {
        windows[window].windowedX = x;
        windows[window].windowedY = y;
    }
}

private extern(C) void resizeCallback(GLFWwindow *window, int w, int h) nothrow 
    in(window in windows)
{
    windows[window].mWidth = w;
    windows[window].mHeight = h;
    if (!windows[window].isFullScreen) {
        windows[window].windowedWidth = w;
        windows[window].windowedHeight = h;
    }
    windows[window].resized = true;
}

private extern(C) void keyCallback(GLFWwindow *window, int key, int scancode, int action, int mods) nothrow {
    if (key == GLFW_KEY_UNKNOWN) {
        windows[window].hasKeyPressed[-scancode] = action == GLFW_PRESS || action == GLFW_REPEAT;
    } else {
        windows[window].hasKeyPressed[key] = action == GLFW_PRESS || action == GLFW_REPEAT;
    }
}
