module sbylib.material.CompassMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.math.Vector;
import sbylib.camera.Camera;

class CompassMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    private Lazy!(uvec2) xvec;
    private Lazy!(uvec2) yvec;
    private Lazy!(uvec2) zvec;
}

class CompassMaterial : MaterialTemp!CompassMaterialUniformKeeper {

    this(Camera camera) {
        super((CompassMaterialUniformKeeper keeper) {
            keeper.xvec = new Lazy!(uvec2)((ref uvec2 xvec) {
                xvec = normalize((camera.worldMatrix.toMatrix3() * vec3(1,0,0)).xy);
            },
            new uvec2("xvec"),
            camera.worldMatrix);
            keeper.yvec = new Lazy!(uvec2)((ref uvec2 yvec) {
                yvec = normalize((camera.worldMatrix.toMatrix3() * vec3(0,1,0)).xy);
            },
            new uvec2("yvec"),
            camera.worldMatrix);
            keeper.zvec = new Lazy!(uvec2)((ref uvec2 zvec) {
                zvec = normalize((camera.worldMatrix.toMatrix3() * vec3(0,0,1)).xy);
            },
            new uvec2("zvec"),
            camera.worldMatrix);
        });
    }
}
