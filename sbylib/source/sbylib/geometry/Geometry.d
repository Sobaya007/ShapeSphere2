module sbylib.geometry.Geometry;

import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.VertexArray;
import sbylib.wrapper.gl.VertexBuffer;
import sbylib.wrapper.gl.IndexBuffer;
import sbylib.wrapper.gl.Attribute;
import sbylib.wrapper.gl.Functions;
import sbylib.geometry.Vertex;
import sbylib.geometry.Face;
import sbylib.material.Material;
import sbylib.utils.Functions;
import sbylib.collision.geometry.CollisionBVH;
import sbylib.collision.CollisionEntry;
import sbylib.entity.Object3D;
import sbylib.math.Vector;

import std.range;
import std.algorithm;
import std.array;
import std.typecons;

interface Geometry {
    void render(VertexArray vao);
    Tuple!(Attribute, VertexBuffer)[] getBuffers();
    IndexBuffer getIndexBuffer();
    void updateBuffer();
    CollisionGeometry[] createCollisionPolygon();
    CollisionCapsule createCollisionCapsule();
    CollisionCapsule createCollisionSphere();

    string toString();
}

alias GeometryP = TypedGeometry!([Attribute.Position]);
alias GeometryN = TypedGeometry!([Attribute.Position, Attribute.Normal]);
alias GeometryT = TypedGeometry!([Attribute.Position, Attribute.UV]);
alias GeometryNT = TypedGeometry!([Attribute.Position, Attribute.Normal, Attribute.UV]);

class VertexGroup(Attribute[] Attributes) {
    alias VertexA = Vertex!(Attributes);
    VertexA[] vertices;
    Tuple!(Attribute, VertexBuffer)[] buffers;

    this(VertexA[] vertices) {
        this.vertices = vertices;
        static foreach (attr; Attributes) {{
            auto buffer = new VertexBuffer;
            float[] data = new float[vertices.length * attr.dim];
            foreach (i, vertex; vertices) {
                data[i*attr.dim..(i+1)*attr.dim] = __traits(getMember, vertex, attr.name.dropOne()).array;
            }
            buffer.sendData(data, BufferUsage.Static);
            this.buffers ~= tuple(attr, buffer);
        }}
    }

    ~this() {
        foreach (attr, buf; buffers) {
            buf.destroy();
        }
    }

    void updateBuffer() {
        static foreach (i, attr; Attributes) {{
            auto buffer = buffers[i][1];
            float* data = cast(float*)buffer.map(BufferAccess.Write);
            foreach (j, v; this.vertices) {
                data[j*attr.dim..(j+1)*attr.dim] = __traits(getMember, v, attr.name.dropOne()).array;
            }
            buffer.unmap();
        }}
    }
}

alias VertexGroupP = VertexGroup!([Attribute.Position]);
alias VertexGroupN = VertexGroup!([Attribute.Position, Attribute.Normal]);
alias VertexGroupT = VertexGroup!([Attribute.Position, Attribute.UV]);
alias VertexGroupNT = VertexGroup!([Attribute.Position, Attribute.Normal, Attribute.UV]);

class FaceGroup(Prim Mode) {
    const Face[] faces;
    const uint indicesCount;
    IndexBuffer ibo;

    this(immutable(uint[]) indices) {
        this.ibo = new IndexBuffer;
        this.ibo.sendData(indices, BufferUsage.Static);
        this.indicesCount = cast(uint)indices.length;
        this.faces = calcFaces(indices);
    }

    ~this() {
        this.ibo.destroy();
    }

    Face[] calcFaces(immutable(uint[]) indices) {
        Face[] faces;
        final switch (Mode) {
        case Prim.Triangle:
            assert(indices.length % 3 == 0);
            faces = new Face[indices.length/3];
            foreach (i, ref face; faces) {
                face = new Face(indices[i*3..(i+1)*3]);
            }
            break;
        case Prim.TriangleStrip:
            faces = new Face[indices.length-2];
            foreach (i, ref face; faces) {
                face = new Face(indices[i..i+3]);
            }
            break;
        case Prim.TriangleFan:
            faces = new Face[indices.length-2];
            foreach (i, ref face; faces) {
                face = new Face([indices[0], indices[i+1], indices[i+2]]);
            }
            break;
        case Prim.Point:
        case Prim.Line:
        case Prim.LineStrip:
        case Prim.LineLoop:
            faces = [];
            break;
        }
        return faces;
    }
}

class TypedGeometry(Attribute[] A, Prim Mode = Prim.Triangle) : Geometry {
    enum Attributes = A;
    alias VertexA = Vertex!(Attributes);
    alias VertexGroupA = VertexGroup!(Attributes);
    alias FaceGroupP = FaceGroup!(Mode);

    VertexGroup!(Attributes) vertexGroup;
    FaceGroup!(Mode) faceGroup;

    this(VertexA[] vertices) {
        this(vertices, iota(cast(uint)vertices.length).array);
    }

    this(VertexA[] vertices, immutable(uint[]) indices) {
        this.vertexGroup = new VertexGroup!(Attributes)(vertices);
        this.faceGroup = new FaceGroup!(Mode)(indices);
    }

    this(VertexGroupA vertexGroup, FaceGroupP faceGroup) {
        this.vertexGroup = vertexGroup;
        this.faceGroup = faceGroup;
    }

    void destroy() {
        vertexGroup.destroy();
        faceGroup.destroy();
    }

    override void render(VertexArray vao) {
        vao.drawElements!uint(Mode, this.faceGroup.indicesCount);
    }

    override Tuple!(Attribute, VertexBuffer)[] getBuffers() {
        return this.vertexGroup.buffers;
    }
    override IndexBuffer getIndexBuffer() {
        return this.faceGroup.ibo;
    }

    override void updateBuffer() {
        this.vertexGroup.updateBuffer();
    }

    override CollisionGeometry[] createCollisionPolygon() {
        CollisionGeometry[] colPolygons;
        foreach (i, face; this.faceGroup.faces) {
            auto poly = new CollisionPolygon(
                    this.vertexGroup.vertices[face.indexList[2]].position,
                    this.vertexGroup.vertices[face.indexList[1]].position,
                    this.vertexGroup.vertices[face.indexList[0]].position);
            colPolygons ~= poly;
        }
        return colPolygons;
    }

    override CollisionCapsule createCollisionCapsule() {
        auto vertices = this.vertexGroup.vertices.map!(v => v.position).array;
        auto basisCandidates = mostDispersionBasis(vertices);
        auto basis = basisCandidates.maxElement!(bc => length(vertices.maxElement!(v => dot(v, bc)) - vertices.minElement!(v => dot(v, bc))));
        auto minV = vertices.minElement!(v => dot(v, basis));
        auto maxV = vertices.maxElement!(v => dot(v, basis));
        auto center = (minV + maxV) / 2;
        auto radius = vertices.map!(v => length((v - center) - dot(v - center, basis) * basis)).maxElement;

        return new CollisionCapsule(radius, minV + basis * radius, maxV - basis * radius);
    }

    override CollisionCapsule createCollisionSphere() {
        auto center = this.vertexGroup.vertices.map!(v => v.position).sum / this.vertexGroup.vertices.length;
        auto radius = this.vertexGroup.vertices.map!(v => length((v.position - center))).maxElement;

        return new CollisionCapsule(radius, vec3(float.epsilon),vec3(-float.epsilon));
    }

    VertexA[] vertices() {
        return this.vertexGroup.vertices;
    }

    const(Face[]) faces() const {
        return this.faceGroup.faces;
    }

    override string toString() {
        import std.conv;
        import sbylib.utils.Functions;
        return Attributes.map!(a => a.name).join(",") ~ "," ~ Mode.to!string;
    }
}
