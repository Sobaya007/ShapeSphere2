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
    private vec4 clearColor = vec4(0, .5, .5, 1);
    private int clearStencil;

    this(Window window) {
        this.window = window;
        this.frameBuffer = DefaultFrameBuffer;
    }

    override void setClearColor(vec4 color) {
        this.clearColor = color;
    }

    override void setClearStencil(int stencil) {
        this.clearStencil = stencil;
    }

    override void clear(ClearMode[] clearMode...) {
        if (clearMode.canFind(ClearMode.Color)) {
            GlFunction.clearColor(this.clearColor);
        }
        if (clearMode.canFind(ClearMode.Stencil)) {
            GlFunction.clearStencil(this.clearStencil);
        }
        GlFunction.clear(clearMode);
    }

    override const(FrameBuffer) getFrameBuffer() {
        return this.frameBuffer;
    }

    override int getWidth() {
        return this.window.getWidth();
    }
    override int getHeight() {
        return this.window.getHeight();
    }
}