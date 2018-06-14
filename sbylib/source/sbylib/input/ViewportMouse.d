module sbylib.input.ViewportMouse;

import sbylib.core.Core;
import sbylib.input.Mouse;
import sbylib.render.Viewport;
import sbylib.math.Vector;

class ViewportMouse {
    private IViewport viewport;
    private Window window;
    private Mouse mouse;

    this(IViewport viewport) {
        this.viewport = viewport;
        this.window = Core().getWindow;
        this.mouse = Core().getMouse;
    }

    vec2 pos() {
        vec2 mousePos = (this.mouse.pos + vec2(1)) * 0.5 * vec2(this.window.width, this.window.height);
        vec2 viewportPos = vec2(this.viewport.getX, this.viewport.getY);
        vec2 viewportSize = vec2(this.viewport.getWidth, this.viewport.getHeight);
        return (mousePos - viewportPos) / viewportSize * 2.0 - vec2(1);
    }

    vec2 dif() const {
        return this.mouse.dif;
    }

    bool inViewport() {
        vec2 p = pos;
        uint w = this.viewport.getWidth;
        uint h = this.viewport.getHeight;
        return 0<=p.x && p.x<w && 0<=p.y && p.y<h;
    }

    bool isPressed(MouseButton button) const {
        return this.mouse.isPressed(button);
    }

    bool justPressed(MouseButton button) const {
        return this.mouse.justPressed(button);
    }

    bool justReleased(MouseButton button) const {
        return this.mouse.justReleased(button);
    }

    bool justPressed() const {
        return this.mouse.justPressed();
    }

    bool justReleased() const {
        return this.mouse.justReleased();
    }

    MouseButton justPressedButton() const {
        return this.mouse.justPressedButton();
    }

    MouseButton justReleasedButton() const {
        return this.mouse.justReleasedButton();
    }
}
