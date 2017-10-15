module sbylib.wrapper.glfw.Window;

import derelict.glfw3.glfw3;
import derelict.opengl;

import std.string, std.stdio;
import sbylib.math.Vector;
import sbylib.wrapper.glfw.Constants;
import sbylib.wrapper.gl.Functions;
import sbylib.core.RenderTarget;

/*
   GLFW準拠のウインドウのクラスです
 */

private Window[GLFWwindow*] windows;

class Window {
    private {
        GLFWwindow *window;
        uint width, height;
        bool resized;
        float aspect;
        string title;
        RenderTarget renderTarget;
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

        RenderTarget getRenderTarget() {
            return this.renderTarget;
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
    }

    package(sbylib) {

        this(string title, int width, int height) {
            this.title = title;
            this.width = width;
            this.height = height;
            this.aspect = cast(float)width / height;
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

            this.setTitle(title);
            this.setSize(width, height);

            auto glver = DerelictGL3.reload();
            writeln("Version = ", glver);
            assert(glver > GLVersion.gl33, "OpenGL version is too low");

            this.renderTarget = new RenderTarget(this);
            windows[this.window] = this;
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
            if (!this.resized) return;
            /* CAUTION : this is 'event'!!!!! so placed here */
            this.resized = false; 
            auto w = width;
            auto h = height;
            if(width > height * aspect) { //width is too big
                w = cast(uint)(h * aspect);
            } else { //height is too big
                h = cast(uint)(w / aspect);
            }
            auto x = (width - w) / 2;
            auto y = (height - h) / 2;
            GlFunction.setViewport(x,y,w,h);
        }

        void swapBuffers() {
            window.glfwSwapBuffers();
        }
    }
}

private extern(C) void resizeCallback(GLFWwindow *window, int w, int h) nothrow {
    assert(window in windows);
    windows[window].width = w;
    windows[window].height = h;
    windows[window].resized = true;
}
