module sbylib.material.TextureMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformTexture;

class TextureMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    utexture texture;

    void constructor() {
        this.texture = new utexture("tex");
    }
}

alias TextureMaterial = MaterialTemp!TextureMaterialUniformKeeper;
