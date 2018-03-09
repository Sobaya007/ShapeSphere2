module sbylib.material.WireframeMaterial;

import sbylib.material.Material;
import sbylib.material.ColorMaterial;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.Constants;
import sbylib.math.Vector;

class WireframeMaterial : ColorMaterial {

    this(vec4 color) {
        super(color);
        this.config.polygonMode = PolygonMode.Line;
    }
}
