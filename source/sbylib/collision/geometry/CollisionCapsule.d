module sbylib.collision.geometry.CollisionCapsule;

import sbylib.math.Vector;
import sbylib.geometry.Geometry;
import sbylib.geometry.geometry3d.Capsule;
import sbylib.mesh.Object3D;
import sbylib.utils.Watcher;

class CollisionCapsule {
    const float radius;
    const float length;
    Object3D obj;
    Watcher!vec3 start;
    Watcher!vec3 end;

    this(float radius, float length) {
        this.radius = radius;
        this.length = length;
        this.obj = new Object3D();
        this.start = new Watcher!vec3((ref vec3 start) {
            start = (obj.worldMatrix * vec4(0, length/2, 0, 1)).xyz;
        });
        this.end = new Watcher!vec3((ref vec3 end) {
            end = (obj.worldMatrix * vec4(0, -length/2, 0, 1)).xyz;
        });
        this.start.addWatch(this.obj.worldMatrix);
        this.end.addWatch(this.obj.worldMatrix);
    }

    Geometry createGeometry() {
        return Capsule.create(this.radius, this.length);
    }
}
