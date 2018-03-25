module sbylib.camera.PerspectiveCamera;

import sbylib.camera.Camera;
import sbylib.wrapper.gl.Uniform;
import sbylib.math.Matrix;
import sbylib.math.Vector;
import sbylib.math.Angle;
import sbylib.entity.Entity;
import sbylib.utils.Change;
import std.math;

/*
   視錐台モデルを採用したカメラです。
   遠近感の出る一般的なカメラで、3D描画に用います。
 */

final class PerspectiveCamera : Camera {
private:
    ChangeObserved!float aspectWperH;
    ChangeObserved!Radian fovy;
    ChangeObserved!float nearZ;
    ChangeObserved!float farZ;
    alias ProjMatrix = Depends!((float aspect, Radian fovy, float near, float far) => mat4.perspective(aspect, fovy, near, far), umat4);
    ProjMatrix _projMatrix;
public:
    Entity entity;
    alias getEntity this;

    this(float aspect, Degree fovy, float nearZ, float farZ) {
        this.aspectWperH = aspect;
        this.fovy = Radian(fovy);
        this.nearZ = nearZ;
        this.farZ = farZ;
        this.entity = new Entity();
        this._projMatrix = ProjMatrix(new umat4("projMatrix"));
        this._projMatrix.depends(this.aspectWperH, this.fovy, this.nearZ, this.farZ);
        this.name = "Perspective Camera";
    }

    override inout(Entity) getEntity() inout {
        return this.entity;
    }

    override @property const(umat4) projMatrix() {
        return this._projMatrix;
    }
}
