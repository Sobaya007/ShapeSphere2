module sbylib.material.TextMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.Texture;
import sbylib.math.Vector;

class TextMaterial : Material {

    mixin ConfigureMaterial;

    utexture tex;
    uvec4[256] textColors;
    ufloat[256] charWidths;

    this() {
        mixin(autoAssignCode);
        super();
    }

    vec4 color(vec4 color) {
        foreach (ref col; textColors) {
            col = color;
        }
        return color;
    }

    float alpha(float a) {
        foreach (ref col; textColors) {
            col.a = a;
        }
        return a;
    }
}
