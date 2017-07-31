module sbylib.material.CompassMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.math.Vector;
import sbylib.camera.Camera;

class CompassMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    Watcher!(uvec2) xvec, yvec, zvec;
}

class CompassMaterial : MaterialTemp!CompassMaterialUniformKeeper {

    this(Camera camera) {
        super((CompassMaterialUniformKeeper keeper) {
            keeper.xvec = new Watcher!(uvec2)((ref uvec2 xvec) {
                xvec = normalize((camera.worldMatrix.toMatrix3() * vec3(1,0,0)).xy);
            }, new uvec2("xvec"));
            keeper.yvec = new Watcher!(uvec2)((ref uvec2 yvec) {
                yvec = normalize((camera.worldMatrix.toMatrix3() * vec3(0,1,0)).xy);
            }, new uvec2("yvec"));
            keeper.zvec = new Watcher!(uvec2)((ref uvec2 zvec) {
                zvec = normalize((camera.worldMatrix.toMatrix3() * vec3(0,0,1)).xy);
            }, new uvec2("zvec"));
            keeper.xvec.addWatch(camera.worldMatrix);
            keeper.yvec.addWatch(camera.worldMatrix);
            keeper.zvec.addWatch(camera.worldMatrix);
        });
    }
}
