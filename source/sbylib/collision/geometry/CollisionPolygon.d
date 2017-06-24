module sbylib.collision.geometry.CollisionPolygon;

import sbylib.math.Vector;
import sbylib.utils.Watcher;

class CollisionPolygon {
    Watch!(vec3)[3] positions;
    Watcher!vec3 normal;

    this() {
        this.positions[0] = new Watch!vec3(vec3(0));
        this.positions[1] = new Watch!vec3(vec3(0));
        this.positions[2] = new Watch!vec3(vec3(0));
        this.normal = new Watcher!vec3((ref vec3 normal) {
            normal = normalize(cross(
                positions[0] - positions[1],
                positions[1] - positions[2]));
        }, vec3(0));
    }
}
