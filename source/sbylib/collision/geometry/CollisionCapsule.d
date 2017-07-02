module sbylib.collision.geometry.CollisionCapsule;

import sbylib.math.Vector;
import sbylib.geometry.Geometry;
import sbylib.geometry.geometry3d.Capsule;
import sbylib.mesh.Object3D;
import sbylib.utils.Watcher;

class CollisionCapsule {
    const float radius;
    Object3D obj;
    vec3 start;
    vec3 end;

    this(float radius, vec3 start, vec3 end) {
        this.radius = radius;
        this.start = start;
        this.end = end;
        this.obj = new Object3D();
    }
}
