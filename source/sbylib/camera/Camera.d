module sbylib.camera.Camera;

public {
    import sbylib.math.Matrix;
    import sbylib.math.Vector;
    import sbylib.mesh.Object3D;
    import sbylib.wrapper.gl.Uniform;
    import sbylib.utils.Watcher;
}

interface Camera {
    inout(Object3D) getObj() inout;
    @property Watcher!umat4 projMatrix();
    alias getObj this;
}
