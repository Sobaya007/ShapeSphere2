module sbylib.core.Leviathan;

import sbylib.collision.geometry.CollisionRay;
import sbylib.collision.CollisionEntry;
import sbylib.mesh.Mesh;
import std.traits;

class Leviathan {
    private ICollidable[] root;

    this() {
    }

    void add(T)(T[] meshes...)
    if (isAssignable!(ICollidable, T)) {
        foreach (m; meshes) {
            this.root ~= m;
        }
    }

    void addAsPolygon(T)(T[] meshes...)
    if (isAssignable!(Mesh, T)) {
        foreach (m; meshes) {
            this.root ~= m.geom.getCollisionPolygons();
        }
    }

    CollisionInfo[] calcCollide(CollisionEntry colEntry) {
        static CollisionInfo[] result;
        result.length = 0;
        foreach (c; this.root) {
            auto colInfo = c.collide(colEntry);
            if (!colInfo.collided) continue;
            result ~= colInfo;
        }
        return result;
    }

    CollisionInfoRay calcCollideRay(CollisionRay ray) {
        CollisionInfoRay result;
        result.colDist = 1145141919.324;
        foreach (c; this.root) {
            auto colInfo = c.collide(ray);
            if (!colInfo.collided) continue;
            if (result.colDist < colInfo.colDist) continue;
            result = colInfo;
        }
        return result;
    }
}
