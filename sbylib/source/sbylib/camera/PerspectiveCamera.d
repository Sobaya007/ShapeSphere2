module sbylib.camera.PerspectiveCamera;

import sbylib.camera.Camera;

/*
   視錐台モデルを採用したカメラです。
   遠近感の出る一般的なカメラで、3D描画に用います。
 */

final class PerspectiveCamera : Camera {

    import sbylib.math.Matrix;
    import sbylib.math.Angle;
    import sbylib.entity.Entity;
    import sbylib.utils.Change;

    ChangeObserved!float aspectWperH;
    ChangeObserved!Radian fovy;
    ChangeObserved!float nearZ;
    ChangeObserved!float farZ;

    alias ProjMatrix = Depends!((float aspect, Radian fovy, float near, float far) => mat4.perspective(aspect, fovy, near, far), umat4);
    private ProjMatrix mProjMatrix;

    Entity mEntity;
    alias entity this;

    this() {
        this.mEntity = new Entity();
        this.mProjMatrix = ProjMatrix(new umat4("projMatrix"));
        this.mProjMatrix.depends(this.aspectWperH, this.fovy, this.nearZ, this.farZ);
        this.name = "Perspective Camera";
    }

    this(float aspect, Degree fovy, float nearZ, float farZ) {
        this.aspectWperH = aspect;
        this.fovy = fovy.toRad;
        this.nearZ = nearZ;
        this.farZ = farZ;
        this();
    }

    override inout(Entity) entity() inout {
        return this.mEntity;
    }

    override @property const(umat4) projMatrix() {
        return this.mProjMatrix;
    }
}
