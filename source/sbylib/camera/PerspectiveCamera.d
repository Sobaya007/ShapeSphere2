module sbylib.camera.PerspectiveCamera;

import sbylib.camera.Camera;
import sbylib.wrapper.gl.Uniform;
import sbylib.mesh.Object3D;
import sbylib.math.Matrix;
import sbylib.math.Vector;
import sbylib.math.Angle;
import sbylib.entity.Entity;
import sbylib.utils.Lazy;
import std.math;

/*
   視錐台モデルを採用したカメラです。
   遠近感の出る一般的なカメラで、3D描画に用います。
 */

final class PerspectiveCamera : Camera {
private:
    Observed!float aspectWperH;
    Observed!Radian fovy;
    Observed!float nearZ;
    Observed!float farZ;
    Observer!umat4 _projMatrix;
public:
    Entity entity;

    this(float aspect, Degree fovy, float nearZ, float farZ) {
        this.aspectWperH = new Observed!float(aspect);
        this.fovy = new Observed!Radian(Radian(fovy));
        this.nearZ = new Observed!float(nearZ);
        this.farZ = new Observed!float(farZ);
        this.entity = new Entity();
        this._projMatrix = new Observer!umat4((ref umat4 mat) {
            mat.value = this.generateProjectionMatrix();
        }, new umat4("projMatrix"));
        this._projMatrix.capture(this.aspectWperH);
        this._projMatrix.capture(this.fovy);
        this._projMatrix.capture(this.nearZ);
        this._projMatrix.capture(this.farZ);
    }

    override inout(Object3D) getObj() inout {
        return this.entity.obj;
    }

    override @property Observer!umat4 projMatrix() {
        return this._projMatrix;
    }

    private mat4 generateProjectionMatrix() {
        return mat4.perspective(aspectWperH, fovy, nearZ, farZ);
    }
}
