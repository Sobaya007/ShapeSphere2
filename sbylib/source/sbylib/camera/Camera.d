module sbylib.camera.Camera;

import sbylib.entity.Entity;
import sbylib.wrapper.gl.Uniform;

interface Camera {
    inout(Entity) entity() inout;
    @property const(umat4) projMatrix();
    alias entity this;
}
