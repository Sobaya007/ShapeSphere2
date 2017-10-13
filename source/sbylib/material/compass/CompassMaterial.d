module sbylib.material.CompassMaterial;

import sbylib.material.Material;
import sbylib.material.MaterialUtils;
import sbylib.material.UniformKeeper;
import sbylib.wrapper.gl.Uniform;
import sbylib.math.Vector;
import sbylib.camera.Camera;

class CompassMaterialUniformKeeper : UniformKeeper {

    mixin MaterialUtils.declare;

    private Watcher!(uvec2) _xvec;
    private Watcher!(uvec2) _yvec;
    private Watcher!(uvec2) _zvec;

    void xvec(vec2 v) {
        this._xvec.get() = v;
    }

    vec2 xvec() {
        return _xvec;
    }

    void yvec(vec2 v) {
        this._yvec.get() = v;
    }

    vec2 yvec() {
        return _yvec;
    }

    void zvec(vec2 v) {
        this._zvec.get() = v;
    }

    vec2 zvec() {
        return _zvec;
    }
}

class CompassMaterial : MaterialTemp!CompassMaterialUniformKeeper {

    this(Camera camera) {
        super((CompassMaterialUniformKeeper keeper) {
            keeper._xvec = new Watcher!(uvec2)((ref uvec2 xvec) {
                xvec = normalize((camera.worldMatrix.toMatrix3() * vec3(1,0,0)).xy);
            }, new uvec2("xvec"));
            keeper._yvec = new Watcher!(uvec2)((ref uvec2 yvec) {
                yvec = normalize((camera.worldMatrix.toMatrix3() * vec3(0,1,0)).xy);
            }, new uvec2("yvec"));
            keeper._zvec = new Watcher!(uvec2)((ref uvec2 zvec) {
                zvec = normalize((camera.worldMatrix.toMatrix3() * vec3(0,0,1)).xy);
            }, new uvec2("zvec"));
            keeper._xvec.addWatch(camera.worldMatrix);
            keeper._yvec.addWatch(camera.worldMatrix);
            keeper._zvec.addWatch(camera.worldMatrix);
        });
    }
}
