module sbylib.entity.Object3D;

import sbylib.math.Matrix;
import sbylib.math.Vector;
import sbylib.math.Quaternion;
import sbylib.utils.Change;
import sbylib.wrapper.gl.Uniform;
import sbylib.entity.Entity;

class Object3D {
    alias WorldMatrix = Depends!((mat4 parent, vec3 pos, mat3 rot, vec3 scale) => parent * mat4.makeTRS(pos, rot, scale), umat4);
    alias ViewMatrix = Depends!((mat4 parent, vec3 pos, mat3 rot, vec3 scale) => parent * mat4.makeInvertTRS(pos, rot, scale), umat4);
    ChangeObserved!vec3 pos;
    ChangeObserved!mat3 rot;
    ChangeObserved!vec3 scale;
    private Entity owner;
    private ChangeObserved!(mat4) parentWorldMatrix;
    private ChangeObserved!(mat4) parentViewMatrix;
    WorldMatrix worldMatrix;
    ViewMatrix viewMatrix;

    this(Entity owner) {
        this.owner = owner;
        this.pos = vec3(0);

        this.rot = mat3.identity();

        this.scale = vec3(1);

        this.worldMatrix = WorldMatrix(new umat4("worldMatrix"));
        this.viewMatrix = ViewMatrix(new umat4("viewMatrix"));

        this.parentWorldMatrix = ChangeObserved!mat4(mat4.identity);
        this.parentViewMatrix = ChangeObserved!mat4(mat4.identity);

        this.worldMatrix.depends(this.parentWorldMatrix, this.pos, this.rot, this.scale);
        this.viewMatrix.depends(this.parentViewMatrix, this.pos, this.rot, this.scale);
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
        this.worldMatrix.depends(parent.worldMatrix, this.pos, this.rot, this.scale);
        this.viewMatrix.depends(parent.viewMatrix, this.pos, this.rot, this.scale);
    }
}
