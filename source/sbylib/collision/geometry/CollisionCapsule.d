module sbylib.collision.geometry.CollisionCapsule;

import sbylib.math.Vector;
import sbylib.geometry.Geometry;
import sbylib.geometry.geometry3d.Capsule;
import sbylib.mesh.Object3D;
import sbylib.utils.Lazy;
import sbylib.collision.CollisionEntry;
import sbylib.collision.geometry.CollisionGeometry;

class CollisionCapsule : CollisionGeometry {
    const float radius;
    private vec3 _start, _end;
    Lazy!vec3 start;
    Lazy!vec3 end;
    private Entity owner;

    invariant {
        if (this.owner !is null) {
            //assert(this.owner.obj.scale == vec3(1));
        }
    }

    this(float radius, vec3 start, vec3 end) {
        this.radius = radius;
        this._start = start;
        this._end = end;
    }

    void setStart(vec3 start) {
        this._start = (this.owner.obj.viewMatrix * vec4(start, 1)).xyz;
    }

    void setEnd(vec3 end) {
        this._end = (this.owner.obj.viewMatrix * vec4(end, 1)).xyz;
    }

    GeometryNT createGeometry() {
        return Capsule.create(this.radius, length(this._start - this._end));
    }

    override void setOwner(Entity owner) {
        this.owner = owner;
        this.start = new Lazy!vec3(
            () => (this.owner.obj.worldMatrix * vec4(_start, 1)).xyz,
            this.owner.obj.worldMatrix
        );
        this.end = new Lazy!vec3(
            () => (this.owner.obj.worldMatrix * vec4(_end, 1)).xyz,
            this.owner.obj.worldMatrix
        );
    }
}
