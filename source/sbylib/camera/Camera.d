module sbylib.camera.Camera;

public {
    import sbylib.math.Matrix;
    import sbylib.math.Vector;
    import sbylib.entity.Entity;
    import sbylib.wrapper.gl.Uniform;
    import sbylib.utils.Lazy;
}

interface Camera {
    inout(Entity) getEntity() inout;
    @property Observer!umat4 projMatrix();
    alias getEntity this;
}
