module sbylib.utils.FunctionPlotter;

import sbylib;

abstract class FunctionPlotter {

    float xLower, xUpper, yLower, yUpper;
    vec4 backgroundColor;

    private FrameBufferObject fbo;

    this() {
        fbo = new FrameBufferObject();
        xLower = yLower = 0;
        xUpper = yUpper = 1;
        backgroundColor = vec4(0,0,0,1);
    }

    abstract void plot(TextureObject tex, vec4 color);
}

class ExplicitFunctionPlotter : FunctionPlotter {

    float delegate(float) func;
    int pointNum = 100;

    this() {
        super();
    }

    override void plot(TextureObject tex, vec4 color) {
        this.fbo.attachTextureAsColor(tex);
        immutable unit = (xUpper - xLower) / pointNum;
        immutable heightInv = 1 / (yUpper - yLower);
        float x = xLower;
        float y = func(x);
        fbo.write(tex.width, tex.height, {
            clearColor(backgroundColor);
            clear(ClearMode.Color);
            foreach (i; 0..pointNum) {
                float newX = x + unit;
                float newY = func(newX);
                drawLine(vec2(cast(float)i / pointNum * 2 - 1, (y - yLower) * heightInv * 2 - 1), vec2(cast(float)(i+1) / pointNum * 2 - 1, (newY - yLower) * heightInv * 2 - 1), color);
                x = newX;
                y = newY;
            }
        });
    }
}
