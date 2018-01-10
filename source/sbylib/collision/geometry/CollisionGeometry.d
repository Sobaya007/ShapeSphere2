module sbylib.collision.geometry.CollisionGeometry;

public {
    import sbylib.entity.Entity;
    import sbylib.math.Vector;
    import sbylib.utils.Change;
}

struct AABB {
    vec3 min, max;

    bool collide(const AABB bound) const {
        if (this.max.x < bound.min.x) return false;
        if (this.max.y < bound.min.y) return false;
        if (this.max.z < bound.min.z) return false;
        if (bound.max.x < this.min.x) return false;
        if (bound.max.y < this.min.y) return false;
        if (bound.max.z < this.min.z) return false;
        return true;
    }
}

interface CollisionGeometry {
    void setOwner(Entity);
    ChangeObserveTarget!AABB getBound();
}
