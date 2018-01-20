module sbylib.camera.OrthoCamera;

public {
    import sbylib.camera.Camera;
    import sbylib.wrapper.gl.Uniform;
    import sbylib.utils.Lazy;
    import sbylib.math.Matrix;
    import sbylib.math.Vector;
    import sbylib.entity.Entity;
}

/*
   平行投影モデルを採用したカメラです。
   遠近感がありませんので、2D描画などに用います。
 */

final class OrthoCamera : Camera {
public:

    Observed!float width;
    Observed!float height;
    Observed!float nearZ;
    Observed!float farZ;

    private Entity entity;
    private Observer!umat4 _projMatrix;

    alias getEntity this;

    this(float width, float height, float nearZ, float farZ) {
        this.width = new Observed!float(width);
        this.height = new Observed!float(height);
        this.nearZ = new Observed!float(nearZ);
        this.farZ = new Observed!float(farZ);
        this.entity = new Entity();
        this._projMatrix = new Observer!umat4((ref umat4 mat) {
            mat.value = this.generateProjectionMatrix();
        }, new umat4("projMatrix"));
        this._projMatrix.capture(this.width);
        this._projMatrix.capture(this.height);
        this._projMatrix.capture(this.nearZ);
        this._projMatrix.capture(this.farZ);
    }

    override inout(Entity) getEntity() inout {
        return this.entity;
    }

    override @property Observer!umat4 projMatrix() {
        return this._projMatrix;
    }

    private mat4 generateProjectionMatrix() {
        return mat4.ortho(width, height, nearZ, farZ);
    }

}
