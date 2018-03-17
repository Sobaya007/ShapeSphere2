module sbylib.material.TextMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformTexture;
import sbylib.math.Vector;

class TextMaterial : Material {

    mixin declare;

    utexture texture;
    uvec4 color;
    uvec4 backColor;

    this() {

        mixin(autoAssignCode);
        super();

        this.color = vec4(1);
        this.backColor = vec4(0);
    }
}