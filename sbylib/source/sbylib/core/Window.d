module sbylib.core.Window;

import sbylib.wrapper.glfw.Window;
import sbylib.render.Screen;
import sbylib.input.Key;
import sbylib.input.Mouse;

private Window[GlfwWindow] windows;

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

        windows[window] = this;
    }

    static Window getCurrentWindow() {
        return windows[GlfwWindow.getCurrentWindow];
    }

    Screen getScreen() {
        return this.screen;
    }

    inout(GlfwWindow) getInternalWindow() inout {
        return this.window;
    }

    Key key() {
        if (mKey is null) {
            mKey = new Key(this);
            import sbylib.core.Core;
            Core().addProcess(&mKey.update, "key.update");
        }
        return mKey;
    }

    Mouse mouse() {
        if (mMouse is null) {
            mMouse = new Mouse(this);
            import sbylib.core.Core;
            Core().addProcess(&mMouse.update, "key.update");
        }
        return mMouse;
    }

    alias getInternalWindow this;
}
