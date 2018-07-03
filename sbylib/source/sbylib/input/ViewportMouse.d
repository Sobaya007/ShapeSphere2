module sbylib.input.ViewportMouse;

import sbylib.core.Core;
import sbylib.input.Mouse;
import sbylib.render.Viewport;
import sbylib.math.Vector;

class ViewportMouse {
    private IViewport viewport;
    private Window window;

    this(IViewport viewport) {
        this.viewport = viewport;
        this.window = Core().getWindow;
    }

    vec2 pos() {
        vec2 mousePos = (Core().mousePos + vec2(1)) * 0.5 * vec2(this.window.width, this.window.height);
        vec2 viewportPos = vec2(this.viewport.getX, this.viewport.getY);
        vec2 viewportSize = vec2(this.viewport.getWidth, this.viewport.getHeight);
        return (mousePos - viewportPos) / viewportSize * 2.0 - vec2(1);
    }

    vec2 dif() const {
        return Core().mouseDif;
    }

    bool inViewport() {
        vec2 p = pos;
        uint w = this.viewport.getWidth;
        uint h = this.viewport.getHeight;
        return 0<=p.x && p.x<w && 0<=p.y && p.y<h;
    }

    bool isPressed(MouseButton button) const {
        return Core().isPressed(button);
    }

    bool justPressed(MouseButton button) const {
        return Core().justPressed(button);
    }

    bool justReleased(MouseButton button) const {
        return Core().justReleased(button);
    }

    bool justPressed() const {
        return Core().justPressed();
    }

    bool justReleased() const {
        return Core().justReleased();
    }

    MouseButton justPressedButton() const {
        return Core().justPressedButton();
    }

    MouseButton justReleasedButton() const {
        return Core().justReleasedButton();
    }
}
