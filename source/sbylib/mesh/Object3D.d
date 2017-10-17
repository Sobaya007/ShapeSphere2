module sbylib.mesh.Object3D;

import sbylib.math.Matrix;
import sbylib.math.Vector;
import sbylib.math.Quaternion;
import sbylib.utils.Lazy;
import sbylib.wrapper.gl.Uniform;
import sbylib.core.Entity;

class Object3D {
    Observed!vec3 _pos;
    Observed!mat3 _rot;
    Observed!vec3 _scale;
    private Observer!mat4 parentWorldMatrix;
    private Observer!mat4 parentViewMatrix;
    private Entity owner;
    private Entity parent;
    Observer!umat4 worldMatrix;
    Observer!umat4 viewMatrix;

    this(Entity owner) {
        this.owner = owner;
        this._pos = new Observed!vec3();
        this._pos = vec3(0);

        this._rot = new Observed!mat3();
        this._rot = mat3.identity();

        this._scale = new Observed!vec3();
        this._scale = vec3(1);

        this.worldMatrix = new Observer!umat4((ref umat4 mat) {
            mat.value = parentWorldMatrix * generateWorldMatrix();
        }, new umat4("worldMatrix"));

        this.viewMatrix = new Observer!umat4((ref umat4 mat) {
            mat.value = parentViewMatrix * generateViewMatrix();
        }, new umat4("viewMatrix"));

        this.parentWorldMatrix = new Observer!mat4((ref mat4 mat) {
            mat = mat4.identity();
        }, mat4.identity());

        this.parentViewMatrix = new Observer!mat4((ref mat4 mat) {
            mat = mat4.identity();
        }, mat4.identity());

        this.worldMatrix.capture(this._pos);
        this.worldMatrix.capture(this._rot);
        this.worldMatrix.capture(this._scale);
        this.worldMatrix.capture(this.parentWorldMatrix);
        this.viewMatrix.capture(this._pos);
        this.viewMatrix.capture(this._rot);
        this.viewMatrix.capture(this._scale);
        this.viewMatrix.capture(this.parentViewMatrix);
    }

    void lookAt(vec3 target, vec3 up = vec3(0,1,0)) {
        this.lookTo(normalize(this.pos - target), up);
    }

    void lookTo(vec3 v, vec3 up = vec3(0,1,0)) {
        auto side = normalize(cross(up, v));
        up = normalize(cross(v, side));
        this.rot = mat3(side, up, v);
    }

    void onSetParent(Entity parent) {
        this.parentWorldMatrix.define((ref mat4 mat) {
            mat = parent.obj.worldMatrix.get().value;
        });
        if (this.parent) this.parentWorldMatrix.release(this.parent.obj.worldMatrix);
        this.parentWorldMatrix.capture(parent.obj.worldMatrix);
        this.parentViewMatrix.define((ref mat4 mat) {
            mat = parent.obj.viewMatrix.get().value;
        });
        if (this.parent) this.parentViewMatrix.release(this.parent.obj.viewMatrix);
        this.parentViewMatrix.capture(parent.obj.viewMatrix);
        this.parent = parent;
    }

    protected mat4 generateWorldMatrix() {
        return mat4(
                scale.x * rot[0,0], scale.y * rot[0,1], scale.z * rot[0,2], pos.x,
                scale.x * rot[1,0], scale.y * rot[1,1], scale.z * rot[1,2], pos.y,
                scale.x * rot[2,0], scale.y * rot[2,1], scale.z * rot[2,2], pos.z,
                0,0,0, 1);
    }

    protected mat4 generateViewMatrix() {
        auto column = rot.column;
        return mat4(
                rot[0,0] / scale.x, rot[1,0] / scale.x, rot[2,0] / scale.x, -dot(column[0], pos) / scale.x,
                rot[0,1] / scale.y, rot[1,1] / scale.y, rot[2,1] / scale.y, -dot(column[1], pos) / scale.y,
                rot[0,2] / scale.z, rot[1,2] / scale.z, rot[2,2] / scale.z, -dot(column[2], pos) / scale.z,
                0,0,0, 1);
    }

    void pos(vec3 p) @property {
        this._pos = p;
    }

    Observed!vec3 pos() @property {
        return this._pos;
    }

    void rot(mat3 p) @property {
        this._rot = p;
    }

    Observed!mat3 rot() @property {
        return this._rot;
    }

    void scale(vec3 p) @property {
        this._scale = p;
    }

    Observed!vec3 scale() @property {
        return this._scale;
    }
}
