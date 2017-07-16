module sbylib.mesh.Object3D;

import sbylib.math.Matrix;
import sbylib.math.Vector;
import sbylib.math.Quaternion;
import sbylib.utils.Watcher;
import sbylib.wrapper.gl.Uniform;

class Object3D {
    Watch!vec3 pos;
    Watch!mat3 rot;
    Watch!vec3 scale;
    private Watcher!mat4 parentWorldMatrix;
    private Watcher!mat4 parentViewMatrix;
    private Object3D parent;
    Watcher!umat4 worldMatrix;
    Watcher!umat4 viewMatrix;

    this() {
        this.pos = new Watch!vec3();
        this.pos = vec3(0);

        this.rot = new Watch!mat3();
        this.rot = mat3.identity();

        this.scale = new Watch!vec3();
        this.scale = vec3(1);

        this.worldMatrix = new Watcher!umat4((ref umat4 mat) {
            mat.value = parentWorldMatrix * generateWorldMatrix();
        }, new umat4("worldMatrix"));

        this.viewMatrix = new Watcher!umat4((ref umat4 mat) {
            mat.value = parentViewMatrix * generateViewMatrix();
        }, new umat4("viewMatrix"));

        this.parentWorldMatrix = new Watcher!mat4((ref mat4 mat) {
            mat = mat4.identity();
        }, mat4.identity());

        this.parentViewMatrix = new Watcher!mat4((ref mat4 mat) {
            mat = mat4.identity();
        }, mat4.identity());

        this.worldMatrix.addWatch(this.pos);
        this.worldMatrix.addWatch(this.rot);
        this.worldMatrix.addWatch(this.scale);
        this.worldMatrix.addWatch(this.parentWorldMatrix);
        this.viewMatrix.addWatch(this.pos);
        this.viewMatrix.addWatch(this.rot);
        this.viewMatrix.addWatch(this.scale);
        this.viewMatrix.addWatch(this.parentViewMatrix);
    }

    void lookAt(vec3 target, vec3 up = vec3(0,1,0)) {
        this.lookTo(normalize(this.pos - target), up);
    }

    void lookTo(vec3 v, vec3 up = vec3(0,1,0)) {
        auto side = normalize(cross(up, v));
        up = normalize(cross(v, side));
        this.rot = mat3(side, up, v);
    }

    void setParent(Object3D obj) {
        this.parentWorldMatrix.setDefineFunc((ref mat4 mat) {
            mat = obj.worldMatrix.get().value;
        });
        if (parent) this.parentWorldMatrix.removeWatch(parent.worldMatrix);
        this.parentWorldMatrix.addWatch(obj.worldMatrix);
        this.parentViewMatrix.setDefineFunc((ref mat4 mat) {
            mat = obj.viewMatrix.get().value;
        });
        if (parent) this.parentViewMatrix.removeWatch(parent.viewMatrix);
        this.parentViewMatrix.addWatch(obj.viewMatrix);
        this.parent = obj;
    }

    protected mat4 generateWorldMatrix() {
        return mat4([
                scale.x * rot[0,0], scale.y * rot[0,1], scale.z * rot[0,2], pos.x,
                scale.x * rot[1,0], scale.y * rot[1,1], scale.z * rot[1,2], pos.y,
                scale.x * rot[2,0], scale.y * rot[2,1], scale.z * rot[2,2], pos.z,
                0,0,0, 1]);
    }

    protected mat4 generateViewMatrix() {
        auto column = rot.column;
        return mat4([
                rot[0,0] / scale.x, rot[1,0] / scale.x, rot[2,0] / scale.x, -dot(column[0], pos) / scale.x,
                rot[0,1] / scale.y, rot[1,1] / scale.y, rot[2,1] / scale.y, -dot(column[1], pos) / scale.y,
                rot[0,2] / scale.z, rot[1,2] / scale.z, rot[2,2] / scale.z, -dot(column[2], pos) / scale.z,
                0,0,0, 1]);
    }
}
