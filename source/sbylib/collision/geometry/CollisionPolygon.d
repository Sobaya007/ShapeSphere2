module sbylib.collision.geometry.CollisionPolygon;

import sbylib.math.Vector;
import sbylib.utils.Lazy;
import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.mesh.Object3D;
import std.algorithm;
import std.array;
import sbylib.collision.CollisionEntry;
import sbylib.collision.geometry.CollisionGeometry;

class CollisionPolygon : CollisionGeometry {
    private vec3[3] _positions;
    private vec3 _normal;
    Lazy!(vec3)[3] positions;
    Lazy!(vec3) normal;
    private Entity owner;

    this(vec3[3] positions...) {
        this._positions = positions;
        this._normal = normalize(cross(positions[2] - positions[1], positions[1] - positions[0]));
    }

    GeometryNT createGeometry() {
        VertexNT[] vertex = new VertexNT[3];
        vertex[0] = new VertexNT(this._positions[0], this._normal, vec2(0,0));
        vertex[1] = new VertexNT(this._positions[1], this._normal, vec2(0.5,1));
        vertex[2] = new VertexNT(this._positions[2], this._normal, vec2(1,0));
        return new GeometryNT(vertex, [0,1,2]);
    }

    override void setOwner(Entity owner) {
        assert(owner !is null);
        this.owner = owner;
        foreach (i; 0..3) {
            (j) {
                this.positions[j] = new Lazy!vec3(
                    () => (this.owner.obj.worldMatrix * vec4(this._positions[j], 1)).xyz,
                    owner.obj.worldMatrix
                );
            }(i);
        }
        this.normal = new Lazy!vec3(
            () => (this.owner.obj.worldMatrix * vec4(this._normal, 0)).xyz,
            this.owner.obj.worldMatrix
        );
    }
}
