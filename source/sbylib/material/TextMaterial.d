module sbylib.material.TextMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformTexture;
import sbylib.math.Vector;

class TextMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    utexture texture;
    uvec4 color;
    uvec4 backColor;

    void constructor() {
        this.texture = new utexture("tex");
        this.color = new uvec4("color");
        this.color = vec4(1);
        this.backColor = new uvec4("backColor");
        this.backColor = vec4(0);
    }
}

alias TextMaterial = MaterialTemp!TextMaterialUniformKeeper;
