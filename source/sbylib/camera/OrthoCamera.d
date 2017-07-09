module sbylib.camera.OrthoCamera;

public {
    import sbylib.camera.Camera;
    import sbylib.wrapper.gl.Uniform;
    import sbylib.mesh.Object3D;
    import sbylib.utils.Watcher;
    import sbylib.math.Matrix;
    import sbylib.math.Vector;
}

/*
   平行投影モデルを採用したカメラです。
   遠近感がありませんので、2D描画などに用います。
 */

final class OrthoCamera : Camera {
public:

    Watch!float width;
    Watch!float height;
    Watch!float nearZ;
    Watch!float farZ;

    Object3D obj;
    private Watcher!umat4 _projMatrix;

    this(float width, float height, float nearZ, float farZ) {
        this.width = new Watch!float(width);
        this.height = new Watch!float(height);
        this.nearZ = new Watch!float(nearZ);
        this.farZ = new Watch!float(farZ);
        this.obj = new Object3D();
        this._projMatrix = new Watcher!umat4((ref umat4 mat) {
            mat.value = this.generateProjectionMatrix();
        }, new umat4("projMatrix"));
        this._projMatrix.addWatch(this.width);
        this._projMatrix.addWatch(this.height);
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
        return mat4.ortho(width, height, nearZ, farZ);
    }

}
