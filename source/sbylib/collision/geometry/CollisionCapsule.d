module sbylib.collision.geometry.CollisionCapsule;

import sbylib.math.Vector;
import sbylib.geometry.Geometry;
import sbylib.geometry.geometry3d.Capsule;
import sbylib.mesh.Object3D;
import sbylib.utils.Watcher;
import sbylib.collision.CollisionEntry;
import sbylib.collision.geometry.CollisionGeometry;

class CollisionCapsule : CollisionGeometry {
    const float radius;
    private vec3 _start, _end;
    Watcher!vec3 start;
    Watcher!vec3 end;
    private CollisionEntry parent;

    this(float radius, vec3 start, vec3 end) {
        this.radius = radius;
        this._start = start;
        this._end = end;
    }

    void setStart(vec3 start) {
        this._start = (this.parent.obj.viewMatrix * vec4(start, 1)).xyz;
    }

    void setEnd(vec3 end) {
        this._end = (this.parent.obj.viewMatrix * vec4(end, 1)).xyz;
    }

    override void setParent(CollisionEntry parent) {
        this.parent = parent;
        this.start = new Watcher!vec3((ref vec3 p) {
            p = (this.parent.obj.worldMatrix * vec4(_start, 1)).xyz;
        });
        this.end = new Watcher!vec3((ref vec3 p) {
            p = (this.parent.obj.worldMatrix * vec4(_end, 1)).xyz;
        });
        this.start.addWatch(this.parent.obj.worldMatrix);
        this.end.addWatch(this.parent.obj.worldMatrix);
    }
}
