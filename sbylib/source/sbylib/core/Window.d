module sbylib.core.Window;

import sbylib.wrapper.glfw.Window;
import sbylib.render.Screen;

class Window {
    private GlfwWindow window;
    private Screen screen;

    this(string title, int width, int height) {
        this.window = new GlfwWindow(title, width, height);
        this.screen = new Screen(this);
    }

    Screen getScreen() {
        return this.screen;
    }

    inout(GlfwWindow) getInternalWindow() inout {
        return this.window;
    }

    alias getInternalWindow this;
}
