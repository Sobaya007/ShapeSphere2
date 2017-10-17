module sbylib.camera.Camera;

public {
    import sbylib.math.Matrix;
    import sbylib.math.Vector;
    import sbylib.mesh.Object3D;
    import sbylib.wrapper.gl.Uniform;
    import sbylib.utils.Lazy;
}

interface Camera {
    inout(Object3D) getObj() inout;
    @property Observer!umat4 projMatrix();
    alias getObj this;
}
