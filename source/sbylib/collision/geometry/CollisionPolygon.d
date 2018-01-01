module sbylib.collision.geometry.CollisionPolygon;

import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.utils.Lazy;
import sbylib.utils.Change;
import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.mesh.Object3D;
import std.algorithm;
import std.array;
import sbylib.collision.CollisionEntry;
import sbylib.collision.geometry.CollisionGeometry;

class CollisionPolygon : CollisionGeometry {
    alias WorldVector = Depends!((mat4 world, vec3 p) => (world * vec4(p, 1)).xyz);
    alias WorldVectorNormalized = Depends!((mat4 world, vec3 p) => normalize((world * vec4(p, 1)).xyz));
    private ChangeObserved!(vec3)[3] positionsLocal;
    private ChangeObserved!(vec3) normalLocal;
    WorldVector[3] positions;
    WorldVectorNormalized normal;
    Observer!(AABB) bound;
    private Entity owner;

    this(vec3[3] positions...) {
        static foreach (i; 0..3) {
            this.positionsLocal[i] = positions[i];
        }
        this.normalLocal = normalize(cross(positions[2] - positions[1], positions[1] - positions[0]));
    }

    GeometryNT createGeometry() {
        VertexNT[] vertex = new VertexNT[3];
        vertex[0] = new VertexNT(this.positionsLocal[0], this.normalLocal, vec2(0,0));
        vertex[1] = new VertexNT(this.positionsLocal[1], this.normalLocal, vec2(0.5,1));
        vertex[2] = new VertexNT(this.positionsLocal[2], this.normalLocal, vec2(1,0));
        return new GeometryNT(vertex, [0,1,2]);
    }

    override void setOwner(Entity owner) {
        assert(owner !is null);
        this.owner = owner;
        foreach (i; 0..3) {
            this.positions[i].depends(this.owner.obj.worldMatrix, this.positionsLocal[i]);
        }
        this.normal.depends(this.owner.obj.worldMatrix, this.normalLocal);
        //this.bound = new Observer!AABB(
        //    () => AABB(
        //        minVector(this.positions[0], minVector(this.positions[1], this.positions[2])),
        //        maxVector(this.positions[0], maxVector(this.positions[1], this.positions[2])),
        //    ),
        //    this.positions[0], this.positions[1], this.positions[2]
        //);
    }

    override AABB getBound() {
        return this.bound;
    }

    Entity getOwner() {
        return this.owner;
    }
}
