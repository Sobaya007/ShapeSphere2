module sbylib.material.CompassMaterial;

import sbylib.material.Material;
import sbylib.wrapper.gl.Uniform;
import sbylib.math.Vector;
import sbylib.camera.Camera;
import sbylib.utils.Change;

class CompassMaterial : Material {

    mixin ConfigureMaterial;

    alias Vec(uint i) = Depends!((mat4 world) => normalize(world.column[i].xy), uvec2);

    private Vec!0 xvec;
    private Vec!1 yvec;
    private Vec!2 zvec;

    this(Camera camera) {
        this.xvec = Vec!0(new uvec2("xvec"));
        this.xvec.depends(camera.worldMatrix);
        this.yvec = Vec!1(new uvec2("yvec"));
        this.yvec.depends(camera.worldMatrix);
        this.zvec = Vec!2(new uvec2("zvec"));
        this.zvec.depends(camera.worldMatrix);
        super();
    }
}
