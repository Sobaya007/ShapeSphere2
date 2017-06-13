module sbylib.camera.PerspectiveCamera;

import sbylib.camera.Camera;
import sbylib.wrapper.gl.Uniform;
import sbylib.mesh.Object3D;
import sbylib.utils.Watcher;
import sbylib.math.Matrix;

/*
   視錐台モデルを採用したカメラです。
   遠近感の出る一般的なカメラで、3D描画に用います。
 */

final class PerspectiveCamera : Camera {
public:
    Watch!float aspectWperH;
    Watch!float fovy;
    Watch!float nearZ;
    Watch!float farZ;

    Object3D obj;
    private Watcher!umat4 _projMatrix;

    this(float aspect, float fovy, float nearZ, float farZ) {
        this.aspectWperH = new Watch!float(aspect);
        this.fovy = new Watch!float(fovy);
        this.nearZ = new Watch!float(nearZ);
        this.farZ = new Watch!float(farZ);
        this.obj = new Object3D();
        this._projMatrix = new Watcher!umat4((ref umat4 mat) {
            mat.value = this.generateProjectionMatrix();
        }, new umat4("projMatrix"));
        this._projMatrix.addWatch(this.aspectWperH);
        this._projMatrix.addWatch(this.fovy);
        this._projMatrix.addWatch(this.nearZ);
        this._projMatrix.addWatch(this.farZ);
    }

    override inout(Object3D) getObj() inout {
        return this.obj;
    }

    override @property Watcher!umat4 projMatrix() {
        return this._projMatrix;
    }

    private mat4 generateProjectionMatrix() {
        return mat4.perspective(aspectWperH, fovy, nearZ, farZ);
    }
}
