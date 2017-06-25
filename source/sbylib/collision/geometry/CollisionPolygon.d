module sbylib.collision.geometry.CollisionPolygon;

import sbylib.math.Vector;
import sbylib.utils.Watcher;
import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.mesh.Object3D;
import std.algorithm;
import std.array;

class CollisionPolygon {
    Watcher!(vec3)[3] positions;
    Watcher!(vec3) normal;
    Object3D obj;

    this(vec3[3] positions) {
        this.obj = new Object3D;
        foreach (i; 0..3) {
            (j) {
                this.positions[j] = new Watcher!vec3((ref vec3 p) {
                    p = (obj.worldMatrix * vec4(positions[j], 1)).xyz;
                }, positions[j]);
                this.positions[j].addWatch(this.obj.worldMatrix);
            }(i);
        }
        auto originNormal = normalize(cross(positions[2] - positions[1], positions[1] - positions[0]));
        this.normal = new Watcher!vec3((ref vec3 n) {
           n = (obj.worldMatrix * vec4(originNormal, 0)).xyz;
        }, originNormal);
        this.normal.addWatch(this.obj.worldMatrix);
    }

    Geometry createGeometry() {
        VertexNT[] vertex = new VertexNT[3];
        vertex[0] = new VertexNT;
        vertex[0].position = this.positions[0];
        vertex[0].normal = this.normal;
        vertex[0].uv = vec2(0,0);
        vertex[1] = new VertexNT;
        vertex[1].position = this.positions[1];
        vertex[1].normal = this.normal;
        vertex[1].uv = vec2(0.5,1);
        vertex[2] = new VertexNT;
        vertex[2].position = this.positions[2];
        vertex[2].normal = this.normal;
        vertex[2].uv = vec2(1,0);
        return new GeometryNT(vertex, [0,1,2]);
    }
}
