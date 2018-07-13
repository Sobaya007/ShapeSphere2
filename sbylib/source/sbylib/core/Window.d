module sbylib.core.Window;

import sbylib.wrapper.glfw.Window;
import sbylib.render.Screen;
import sbylib.input.Key;
import sbylib.input.Mouse;

class Window {
    private GlfwWindow window;
    private Screen screen;
    private Key mKey;
    private Mouse mMouse;

    this(string title, int width, int height) {
        this.window = new GlfwWindow(title, width, height);
        this.screen = new Screen(this);

        import sbylib.core.Core;
        Core().addProcess({
            this.window.swapBuffers();
            this.window.pollEvents();
        }, "window");
    }

    Screen getScreen() {
        return this.screen;
    }

    inout(GlfwWindow) getInternalWindow() inout {
        return this.window;
    }

    Key key() {
        if (mKey is null) mKey = new Key(this);
        return mKey;
    }

    Mouse mouse() {
        if (mMouse is null) mMouse = new Mouse(this);
        return mMouse;
    }

    alias getInternalWindow this;
}
