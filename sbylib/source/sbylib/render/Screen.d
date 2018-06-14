module sbylib.render.Screen;

import std.algorithm, std.stdio;
import sbylib.render.RenderTarget;
import sbylib.math.Vector;
import sbylib.core.Window;
import sbylib.wrapper.gl.FrameBuffer;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Functions;

class Screen : IRenderTarget {

    private const FrameBuffer frameBuffer;
    private Window window;

    this(Window window) {
        this.window = window;
        this.frameBuffer = DefaultFrameBuffer;
    }

    override const(FrameBuffer) getFrameBuffer() {
        return this.frameBuffer;
    }

    override int width() {
        return this.window.width;
    }
    override int height() {
        return this.window.height;
    }
}
