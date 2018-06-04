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

    private Entity entity;
    alias ProjMatrix = Depends!((float width, float height, float near, float far) => mat4.ortho(width, height, near, far), umat4);
    private ProjMatrix _projMatrix;

    alias getEntity this;

    this(float width, float height, float nearZ, float farZ) {
        this.width = width;
        this.height = height;
        this.nearZ = nearZ;
        this.farZ = farZ;
        this.entity = new Entity();
        this._projMatrix = ProjMatrix(new umat4("projMatrix"));
        this._projMatrix.depends(this.width, this.height, this.nearZ, this.farZ);
        this.name = "Ortho Camera";
    }

    override inout(Entity) getEntity() inout {
        return this.entity;
    }

    override @property const(umat4) projMatrix() {
        return this._projMatrix;
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
        this.camera = new OrthoCamera(window.getWidth(), window.getHeight(), -1, 1);
        this.window.addResizeCallback({
            this.camera.width = this.window.getWidth();
            this.camera.height = this.window.getHeight();
        });
    }
}
