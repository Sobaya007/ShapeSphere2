module sbylib.material.CompassMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.math.Vector;
import sbylib.camera.Camera;
import sbylib.utils.Change;

class CompassMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    alias Vec(uint i) = Depends!((mat4 world) => normalize(world.column[i].xy), uvec2);

    private Vec!0 xvec;
    private Vec!1 yvec;
    private Vec!2 zvec;
}

class CompassMaterial : MaterialTemp!CompassMaterialUniformKeeper {

    alias Keeper = CompassMaterialUniformKeeper;
    this(Camera camera) {
        super((Keeper keeper) {
            keeper.xvec = Keeper.Vec!0(new uvec2("xvec"));
            keeper.xvec.depends(camera.worldMatrix);
            keeper.yvec = Keeper.Vec!1(new uvec2("yvec"));
            keeper.yvec.depends(camera.worldMatrix);
            keeper.zvec = Keeper.Vec!2(new uvec2("zvec"));
            keeper.zvec.depends(camera.worldMatrix);
        });
    }
}
