module sbylib.wrapper.glfw.Window;

import derelict.glfw3.glfw3;
import derelict.opengl;

import std.string, std.stdio;
import sbylib.math;

/*
   GLFW準拠のウインドウのクラスです
 */

class Window {
private:
    int _width, _height;
    int[4] _viewport;
    string _title;
    vec2i _pos;
    GLFWwindow *window;

public:

    this(string _title, int width, int height) {
        this._title = _title;
        this._width = width;
        this._height = height;
        glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR,4);
        glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR,3);
        glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
        window = glfwCreateWindow(width, height,title.toStringz, null, null);
        if(!window){
            assert(false, "Failed to create window");
        }
        setViewport(0,0, width, height);
        pos = vec2i(100,100);

        glfwMakeContextCurrent(window);

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
        _width = width;
        _height = height;
        glfwSetWindowSize(window, width, height);
    }

    void setViewport(int left, int right, int width, int height) {
        glViewport(left, right, width, height);
    }

@property:

    void title(string title) {
        this._title = title;
        window.glfwSetWindowTitle(title.toStringz);
    }

    string title() {
        return _title;
    }

    void pos(vec2i pos) {
        _pos = pos;
        window.glfwSetWindowPos(pos.x, pos.y);
    }

    vec2i pos() {
        return _pos;
    }

    int width() {
        return _width;
    }

    ///width & height
    int height() {
        return _height;
    }

    int viewportLeft() {
        int[4] data;
        glGetIntegerv(GL_VIEWPORT, data.ptr);
        return data[0];
    }

    int viewportTop() {
        int[4] data;
        glGetIntegerv(GL_VIEWPORT, data.ptr);
        return data[1];
    }

    int viewportWidth() {
        int[4] data;
        glGetIntegerv(GL_VIEWPORT, data.ptr);
        return data[2];
    }

    int viewportHeight() {
        int[4] data;
        glGetIntegerv(GL_VIEWPORT, data.ptr);
        return data[3];
    }

    bool getKey(int key) {
        return glfwGetKey(this.window, key) != 0;
    }

    bool getMouseButton(int button) {
        return glfwGetMouseButton(this.window, button) == GLFW_PRESS;
    }

    void pollEvents() {
        glfwPollEvents();
    }

}
