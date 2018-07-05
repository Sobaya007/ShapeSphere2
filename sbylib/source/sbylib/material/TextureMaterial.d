module sbylib.material.TextureMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.Texture;
import sbylib.wrapper.freeimage.Image;

class TextureMaterial : Material {

    mixin ConfigureMaterial;

    utexture texture;
    ufloat alpha;

    this() {
        mixin(autoAssignCode);
        super();

        this.alpha = 1;
    }

    this(Texture texture) {
        mixin(autoAssignCode);
        super();
        this.texture = texture;
        this.alpha = 1;
    }

    this(Image image) {
        import sbylib.utils.Functions : generateTexture;
        this(generateTexture(image));
    }
}
