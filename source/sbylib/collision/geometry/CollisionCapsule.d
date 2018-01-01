module sbylib.collision.geometry.CollisionCapsule;

import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.geometry.Geometry;
import sbylib.geometry.geometry3d.Capsule;
import sbylib.mesh.Object3D;
import sbylib.utils.Lazy;
import sbylib.utils.Change;
import sbylib.collision.CollisionEntry;
import sbylib.collision.geometry.CollisionGeometry;

class CollisionCapsule : CollisionGeometry {
    ChangeObserved!(float) radius;
    private ChangeObserved!(vec3) startLocal;
    private ChangeObserved!(vec3) endLocal;
    alias WorldPos = Depends!((mat4 world, vec3 p) => (world * vec4(p, 1)).xyz);
    WorldPos start;
    WorldPos end;
    alias Bound = Depends!((vec3 start, vec3 end, float radius) => AABB(minVector(start, end) - vec3(radius), maxVector(start, end) + vec3(radius)));
    Bound bound;
    private Entity owner;

    this(float radius, vec3 start, vec3 end) {
        this.radius = radius;
        this.startLocal = start;
        this.endLocal = end;
    }

    void setStart(const vec3 start) {
        this.startLocal = (this.owner.obj.viewMatrix * vec4(start, 1)).xyz;
    }

    void setEnd(const vec3 end) {
        this.endLocal = (this.owner.obj.viewMatrix * vec4(end, 1)).xyz;
    }

    GeometryNT createGeometry() {
        return Capsule.create(this.radius, length(this.startLocal - this.endLocal));
    }

    override void setOwner(Entity owner) {
        this.owner = owner;
        this.start.depends(owner.worldMatrix, this.startLocal);
        this.end.depends(owner.worldMatrix, this.endLocal);
        this.bound.depends(this.start, this.end, this.radius);
    }

    override AABB getBound() {
        return this.bound;
    }

    Entity getOwner() {
        return this.owner;
    }
}
