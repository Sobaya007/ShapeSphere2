module sbylib.mesh.Object3D;

import sbylib.math.Matrix;
import sbylib.math.Vector;
import sbylib.math.Quaternion;
import sbylib.utils.Watcher;
import sbylib.wrapper.gl.Uniform;

class Object3D {
    Watch!vec3 pos;
    Watch!mat3 rot;
    Watcher!umat4 worldMatrix;
    Watcher!umat4 viewMatrix;

    this() {
        this.pos = new Watch!vec3();
        this.pos = vec3(0);

        this.rot = new Watch!mat3();
        this.rot = mat3.identity();

        this.worldMatrix = new Watcher!umat4((ref umat4 mat) {
            mat.value = generateWorldMatrix();
        }, new umat4("worldMatrix"));
        this.worldMatrix.addWatch(this.pos);
        this.worldMatrix.addWatch(this.rot);

        this.viewMatrix = new Watcher!umat4((ref umat4 mat) {
            mat.value = generateViewMatrix();
        }, new umat4("viewMatrix"));
        this.viewMatrix.addWatch(this.pos);
        this.viewMatrix.addWatch(this.rot);
    }

    void lookAt(vec3 target, vec3 up = vec3(0,1,0)) {
        this.lookTo(normalize(this.pos - target), up);
    }

    void lookTo(vec3 v, vec3 up = vec3(0,1,0)) {
        auto side = normalize(cross(up, v));
        up = normalize(cross(v, side));
        this.rot = mat3(side, up, v);
    }

    private mat4 generateWorldMatrix() {
        return mat4([
                rot[0,0], rot[0,1], rot[0,2], pos.x,
                rot[1,0], rot[1,1], rot[1,2], pos.y,
                rot[2,0], rot[2,1], rot[2,2], pos.z,
                0,0,0, 1]);
    }

    private mat4 generateViewMatrix() {
        auto column = rot.column;
        return mat4([
                rot[0,0], rot[1,0], rot[2,0], -dot(column[0], pos),
                rot[0,1], rot[1,1], rot[2,1], -dot(column[1], pos),
                rot[0,2], rot[1,2], rot[2,2], -dot(column[2], pos),
                0,0,0, 1]);
    }
}
