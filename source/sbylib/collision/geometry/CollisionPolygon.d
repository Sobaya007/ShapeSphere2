module sbylib.collision.geometry.CollisionPolygon;

import sbylib.math.Vector;
import sbylib.utils.Watcher;
import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.mesh.Object3D;
import std.algorithm;
import std.array;
import sbylib.collision.CollisionEntry;
import sbylib.collision.geometry.CollisionGeometry;

class CollisionPolygon : CollisionGeometry {
    private vec3[3] _positions;
    Watcher!(vec3)[3] positions;
    Watcher!(vec3) normal;
    private Entity owner;

    this(vec3[3] positions...) {
        this._positions = positions;
    }

    GeometryNT createGeometry() in {
        assert(this.normal);
    } body {
        VertexNT[] vertex = new VertexNT[3];
        vertex[0] = new VertexNT(this.positions[0], this.normal, vec2(0,0));
        vertex[1] = new VertexNT(this.positions[1], this.normal, vec2(0.5,1));
        vertex[2] = new VertexNT(this.positions[2], this.normal, vec2(1,0));
        return new GeometryNT(vertex, [0,1,2]);
    }

    override void setOwner(Entity owner) {
        this.owner = owner;
        foreach (i; 0..3) {
            (j) {
                this.positions[j] = new Watcher!vec3((ref vec3 p) {
                    p = (this.owner.obj.worldMatrix * vec4(this._positions[j], 1)).xyz;
                }, this._positions[j]);
                this.positions[j].addWatch(this.owner.obj.worldMatrix);
            }(i);
        }
        auto originNormal = normalize(cross(positions[2] - positions[1], positions[1] - positions[0]));
        this.normal = new Watcher!vec3((ref vec3 n) {
           n = (this.owner.obj.worldMatrix * vec4(originNormal, 0)).xyz;
        }, originNormal);
        this.normal.addWatch(this.owner.obj.worldMatrix);
    }
}
