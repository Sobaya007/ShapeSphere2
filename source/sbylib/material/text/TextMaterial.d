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
    uvec3 color;

    void constructor() {
        this.texture = new utexture("tex");
        this.color = new uvec3("color");
        this.color = vec3(0);
    }
}

alias TextMaterial = MaterialTemp!TextMaterialUniformKeeper;
