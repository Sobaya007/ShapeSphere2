module sbylib.collision.geometry.CollisionCapsule;

import sbylib.collision.geometry.CollisionGeometry;

class CollisionCapsule : CollisionGeometry {
    import sbylib.entity.Entity;
    import sbylib.math.Matrix;
    import sbylib.math.Vector;
    import sbylib.utils.Change;

    ChangeObserved!(float) radius;
    private ChangeObserved!(vec3) startLocal;
    private ChangeObserved!(vec3) endLocal;
    alias WorldPos = Depends!((mat4 world, vec3 p) => (world * vec4(p, 1)).xyz);
    WorldPos start;
    WorldPos end;
    alias Bound = Depends!((vec3 start, vec3 end, float radius) => AABB(minVector(start, end) - vec3(radius), maxVector(start, end) + vec3(radius)));
    Bound bound;
    private Entity mOwner;

    this(float radius, vec3 start, vec3 end) {
        this.radius = radius;
        this.startLocal = start;
        this.endLocal = end;
    }

    void setStart(const vec3 start) {
        this.startLocal = (this.mOwner.viewMatrix * vec4(start, 1)).xyz;
    }

    void setEnd(const vec3 end) {
        this.endLocal = (this.mOwner.viewMatrix * vec4(end, 1)).xyz;
    }

    auto createGeometry() {
        import sbylib.geometry.geometry3d.Capsule;
        return Capsule.create(this.radius, this.startLocal, this.endLocal, 10, 10);
    }

    override void setOwner(Entity mOwner) {
        this.mOwner = mOwner;
        this.start.depends(mOwner.worldMatrix, this.startLocal);
        this.end.depends(mOwner.worldMatrix, this.endLocal);
        this.bound.depends(this.start, this.end, this.radius);
    }

    override ChangeObserveTarget!AABB getBound() {
        return this.bound.getTarget();
    }

    Entity owner() {
        return this.mOwner;
    }

    override string toString() {
        return typeof(this).stringof;
    }
}
