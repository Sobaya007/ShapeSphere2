module sbylib.material.TextureMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.UniformTexture;
import sbylib.wrapper.freeimage.Image;

class TextureMaterial : Material {

    mixin declare;

    utexture texture;

    this() {
        mixin(autoAssignCode);
        super();
    }

    this(Texture texture) {
        mixin(autoAssignCode);
        super();
        this.texture = texture;
    }

    this(Image image) {
        import sbylib.utils.Functions : generateTexture;
        this(generateTexture(image));
    }
}
