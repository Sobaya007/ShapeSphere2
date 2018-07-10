module sbylib.collision.geometry.CollisionGeometry;

struct AABB {
    import sbylib.math.Vector;
    import sbylib.collision.geometry.CollisionRay;

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

    bool collide(const CollisionRay ray) const {
        float[6] times;
        times[0..3] = ((this.min - ray.start) / ray.dir).array;
        times[3..6] = ((this.max - ray.start) / ray.dir).array;
        foreach (time; times) {
            if (!(time >= 0)) continue; //avoid NaN
            auto p = ray.start + time * ray.dir;
            if (p.x < min.x - 1e-3) continue;
            if (p.y < min.y - 1e-3) continue;
            if (p.z < min.z - 1e-3) continue;
            if (p.x > max.x + 1e-3) continue;
            if (p.y > max.y + 1e-3) continue;
            if (p.z > max.z + 1e-3) continue;
            return true;
        }
        return false;
    }
}

interface CollisionGeometry {
    import sbylib.entity.Entity;
    import sbylib.utils.Change;

    void setOwner(Entity e) in(e !is null);
    ChangeObserveTarget!AABB getBound();
    string toString();
}
