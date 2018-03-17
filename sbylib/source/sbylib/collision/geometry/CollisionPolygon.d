module sbylib.collision.geometry.CollisionPolygon;

import sbylib.math.Vector;
import sbylib.math.Matrix;
import sbylib.utils.Change;
import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.entity.Object3D;
import std.algorithm;
import std.array;
import sbylib.collision.CollisionEntry;
import sbylib.collision.geometry.CollisionGeometry;

class CollisionPolygon : CollisionGeometry {
    alias WorldVector = Depends!((mat4 world, vec3 p) => (world * vec4(p, 1)).xyz);
    alias WorldVectorNormalized = Depends!((mat4 world, vec3 p) => normalize((world * vec4(p, 0)).xyz));
    private ChangeObserved!(vec3)[3] localPositions;
    ChangeObserved!(vec3) localNormal;
    private ChangeObserved!mat4 dummy;
    WorldVector[3] positions;
    WorldVectorNormalized normal;
    import std.algorithm;
    Depends!((vec3 v0, vec3 v1, vec3 v2) => AABB(minVector(v0, minVector(v1, v2)), maxVector(v0, maxVector(v1, v2)))) bound;
    private Entity owner;

    this(vec3[3] positions...) {
        this.dummy = mat4.identity;
        this.positions[0].depends(this.dummy, this.localPositions[0]);
        this.positions[1].depends(this.dummy, this.localPositions[1]);
        this.positions[2].depends(this.dummy, this.localPositions[2]);
        this.normal.depends(this.dummy, this.localNormal);
        this.bound.depends(this.positions[0], this.positions[1], this.positions[2]);

        this.localPositions[0] = positions[0];
        this.localPositions[1] = positions[1];
        this.localPositions[2] = positions[2];
        this.localNormal = normalize(cross(positions[2] - positions[1], positions[1] - positions[0]));
    }

    GeometryNT createGeometry() {
        VertexNT[] vertex = new VertexNT[3];
        vertex[0] = new VertexNT(this.localPositions[0], this.localNormal, vec2(0,0));
        vertex[1] = new VertexNT(this.localPositions[1], this.localNormal, vec2(0.5,1));
        vertex[2] = new VertexNT(this.localPositions[2], this.localNormal, vec2(1,0));
        return new GeometryNT(vertex, [0,1,2]);
    }

    override void setOwner(Entity owner) {
        assert(owner !is null);
        this.owner = owner;
        this.positions[0].depends(this.owner.worldMatrix, this.localPositions[0]);
        this.positions[1].depends(this.owner.worldMatrix, this.localPositions[1]);
        this.positions[2].depends(this.owner.worldMatrix, this.localPositions[2]);
        this.normal.depends(this.owner.worldMatrix, this.localNormal);
        this.bound.depends(this.positions[0], this.positions[1], this.positions[2]);
    }

    override ChangeObserveTarget!AABB getBound() {
        return this.bound.getTarget();
    }

    Entity getOwner() {
        return this.owner;
    }

    override string toString() {
        return typeof(this).stringof;
    }
}