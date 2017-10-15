module sbylib.material.CompassMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.math.Vector;
import sbylib.camera.Camera;

class CompassMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    private Observer!(uvec2) _xvec;
    private Observer!(uvec2) _yvec;
    private Observer!(uvec2) _zvec;
}

class CompassMaterial : MaterialTemp!CompassMaterialUniformKeeper {

    this(Camera camera) {
        super((CompassMaterialUniformKeeper keeper) {
            keeper._xvec = new Observer!(uvec2)((ref uvec2 xvec) {
                xvec = normalize((camera.worldMatrix.toMatrix3() * vec3(1,0,0)).xy);
            }, new uvec2("xvec"));
            keeper._yvec = new Observer!(uvec2)((ref uvec2 yvec) {
                yvec = normalize((camera.worldMatrix.toMatrix3() * vec3(0,1,0)).xy);
            }, new uvec2("yvec"));
            keeper._zvec = new Observer!(uvec2)((ref uvec2 zvec) {
                zvec = normalize((camera.worldMatrix.toMatrix3() * vec3(0,0,1)).xy);
            }, new uvec2("zvec"));
            keeper._xvec.capture(camera.worldMatrix);
            keeper._yvec.capture(camera.worldMatrix);
            keeper._zvec.capture(camera.worldMatrix);
        });
    }
}
