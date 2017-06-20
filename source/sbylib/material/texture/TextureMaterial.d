module sbylib.material.TextureMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformTexture;

class TextureMaterial : Material {

    mixin MaterialUtils.declare;

    utexture texture; 

    this() {
        mixin(MaterialUtils.init());
        this.texture = new utexture("tex");

        this.setUniform(() => this.texture);
    }
}
