module sbylib.camera.OrthoCamera;

public {
    import sbylib.camera.Camera;
    import sbylib.wrapper.gl.Uniform;
    import sbylib.math.Matrix;
    import sbylib.math.Vector;
    import sbylib.entity.Entity;
    import sbylib.utils.Change;
}

/*
   平行投影モデルを採用したカメラです。
   遠近感がありませんので、2D描画などに用います。
 */

final class OrthoCamera : Camera {
public:

    ChangeObserved!float width;
    ChangeObserved!float height;
    ChangeObserved!float nearZ;
    ChangeObserved!float farZ;

    private Entity mEntity;
    alias ProjMatrix = Depends!((float width, float height, float near, float far) => mat4.ortho(width, height, near, far), umat4);
    private ProjMatrix mProjMatrix;

    alias entity this;

    this(float width, float height, float nearZ, float farZ) {
        this.width = width;
        this.height = height;
        this.nearZ = nearZ;
        this.farZ = farZ;
        this.mEntity = new Entity();
        this.mProjMatrix = ProjMatrix(new umat4("projMatrix"));
        this.mProjMatrix.depends(this.width, this.height, this.nearZ, this.farZ);
        this.name = "Ortho Camera";
    }

    override inout(Entity) entity() inout {
        return this.mEntity;
    }

    override @property const(umat4) projMatrix() {
        return this.mProjMatrix;
    }

}

final class PixelCamera {

    import sbylib.core.Core;
    import sbylib.core.Window;

    private Window window;
    OrthoCamera camera;

    alias camera this;

    this(Window window = Core().getWindow()) {
        this.window = window;
        this.camera = new OrthoCamera(window.width, window.height, -1, 1);
        this.window.addResizeCallback({
            this.camera.width = this.window.width;
            this.camera.height = this.window.height;
        });
    }
}
