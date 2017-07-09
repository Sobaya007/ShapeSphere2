module sbylib.mesh.Object3DS;

import sbylib.math.Matrix;
import sbylib.math.Vector;
import sbylib.math.Quaternion;
import sbylib.utils.Watcher;
import sbylib.wrapper.gl.Uniform;
import sbylib.mesh.Object3D;

class Object3DS : Object3D {

    Watch!vec3 scale;

    this() {
        super();
        this.scale = new Watch!vec3();
        this.scale = vec3(1);
        this.worldMatrix.addWatch(scale);
        this.viewMatrix.addWatch(scale);
    }

    override protected mat4 generateWorldMatrix() {
        return mat4([
                scale.x * rot[0,0], scale.y * rot[0,1], scale.z * rot[0,2], pos.x,
                scale.x * rot[1,0], scale.y * rot[1,1], scale.z * rot[1,2], pos.y,
                scale.x * rot[2,0], scale.y * rot[2,1], scale.z * rot[2,2], pos.z,
                0,0,0, 1]);
    }

    override protected mat4 generateViewMatrix() {
        auto column = rot.column;
        return mat4([
                rot[0,0] / scale.x, rot[1,0] / scale.x, rot[2,0] / scale.x, -dot(column[0], pos) / scale.x,
                rot[0,1] / scale.y, rot[1,1] / scale.y, rot[2,1] / scale.y, -dot(column[1], pos) / scale.y,
                rot[0,2] / scale.z, rot[1,2] / scale.z, rot[2,2] / scale.z, -dot(column[2], pos) / scale.z,
                0,0,0, 1]);
    }
}
