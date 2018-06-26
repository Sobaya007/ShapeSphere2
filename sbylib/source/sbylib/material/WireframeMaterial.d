module sbylib.material.WireframeMaterial;

import sbylib.material.Material;
import sbylib.material.ColorMaterial;
import sbylib.wrapper.gl.Uniform;
import sbylib.wrapper.gl.Constants;
import sbylib.math.Vector;

class WireframeMaterial : ColorMaterial {

    this() {
        super();
        this.config.polygonMode = PolygonMode.Line;
    }

    this(vec4 color) {
        this();
        this.color = color;
    }
}
