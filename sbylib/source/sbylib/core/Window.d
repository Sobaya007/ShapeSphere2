module sbylib.core.Window;

import sbylib.wrapper.glfw.Window;
import sbylib.render.Screen;
import sbylib.render.RenderTarget;
import sbylib.input.Key;
import sbylib.input.Mouse;

private Window[GlfwWindow] windows;

class Window {
    private GlfwWindow window;
    private RenderTarget target;
    private Screen screen;
    private Key mKey;
    private Mouse mMouse;

    this(string title, int width, int height) {
        this.window = new GlfwWindow(title, width, height);
        this.screen = new Screen(this);

        import sbylib.core.Core;
        Core().addProcess({
            import sbylib.wrapper.gl.Constants;
            IRenderTarget screen = this.getScreen();
            this.window.makeCurrent();
            screen.blitsTo(0, 0, this.window.width, this.window.height, this.screen, 0, 0, this.window.width, this.window.height, BufferBit.Color);
            this.window.swapBuffers();
            this.window.pollEvents();
        }, "window");
        this.window.addResizeCallback({
            this.getScreen().resize(this.window.width, this.window.height);
        });

        windows[window] = this;
    }

    static Window getCurrentWindow() {
        return windows[GlfwWindow.getCurrentWindow];
    }

    RenderTarget getScreen() {
        if (this.target is null) {
            import sbylib.wrapper.gl.Constants;
            this.window.makeCurrent();
            this.target = new RenderTarget(width, height);
            this.target.attachTexture!(ubyte)(FramebufferAttachType.Color0);
            this.target.attachTexture!(float)(FramebufferAttachType.Color1); // for ID buffer
            this.target.attachTexture!(ubyte)(FramebufferAttachType.Depth);
            this.target.attachTexture!(ubyte)(FramebufferAttachType.Stencil);
        }
        return this.target;
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
