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
import sbylib.mesh.Object3D;
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
}

alias GeometryP = GeometryTemp!([Attribute.Position]);
alias GeometryN = GeometryTemp!([Attribute.Position, Attribute.Normal]);
alias GeometryT = GeometryTemp!([Attribute.Position, Attribute.UV]);
alias GeometryNT = GeometryTemp!([Attribute.Position, Attribute.Normal, Attribute.UV]);

class GeometryTemp(Attribute[] A, Prim Mode = Prim.Triangle) : Geometry {
    enum Attributes = A;
    alias VertexA = Vertex!(Attributes);

    VertexA[] vertices;
    const Face[] faces;
    const uint indicesCount;
    private IndexBuffer ibo;
    private Tuple!(Attribute, VertexBuffer)[] buffers;
    float delegate(vec3, vec3) getRayIntersectParameter;

    this(VertexA[] vertices) {
        this(vertices, iota(cast(uint)vertices.length).array);
    }

    this(VertexA[] vertices, uint[] indices) {
        this.vertices = vertices;
        foreach (attr; Utils.Range!(Attribute, Attributes)) {
            auto buffer = new VertexBuffer;
            buffer.sendData(vertices.map!(vertex => __traits(getMember, vertex, attr.name.dropOne()).array).reduce!((a,b) => a ~ b), BufferUsage.Static);
            this.buffers ~= tuple(attr, buffer);
        }
        this.ibo = new IndexBuffer;
        this.ibo.sendData(indices, BufferUsage.Static);
        this.indicesCount = cast(uint)indices.length;
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
        case Prim.Line:
        case Prim.LineStrip:
        case Prim.LineLoop:
            faces = [];
            break;
        }
        this.faces = faces;
        this.getRayIntersectParameter = (vec3 s, vec3 v) => minElement(this.faces.map!((face) {
                auto n = cross(
                this.vertices[face.indexList[2]].position - this.vertices[face.indexList[1]].position,
                this.vertices[face.indexList[1]].position - this.vertices[face.indexList[0]].position);
                if (dot(v,n) == 0) return 1145141919.810;
                auto t = dot(this.vertices[face.indexList[0]].position - s, n) / dot(v, n);
                if (t < 0) return 8939311919.810;
                auto p = s + t * n;
                auto signs = face.indexList.map!(i => 
                    cross(this.vertices[(i+1)%3].position - this.vertices[i].position, this.vertices[i].position - p).dot(n)).array;
                if (signs.all!(sign => sign >= 0) || signs.all!(sign => sign < 0)) {
                    return t;
                }
                return 114514893810.1919;
            }));
    }

    override void render(VertexArray vao) {
        vao.drawElements!uint(Mode, this.indicesCount);
    }

    override Tuple!(Attribute, VertexBuffer)[] getBuffers() {
        return this.buffers;
    }
    override IndexBuffer getIndexBuffer() {
        return this.ibo;
    }

    override void updateBuffer() {
        foreach (i, attr; Utils.Range!(Attribute, Attributes)) {
            auto buffer = buffers[i][1];
            float* data = cast(float*)buffer.map(BufferAccess.Write);
            foreach (j, v; this.vertices) {
                data[j*attr.dim..(j+1)*attr.dim] = __traits(getMember, v, attr.name.dropOne()).array;
            }
            buffer.unmap();
        }
    }

    override CollisionGeometry[] createCollisionPolygon() {
        CollisionGeometry[] colPolygons;
        foreach (i, face; this.faces) {
            auto poly = new CollisionPolygon(
                    this.vertices[face.indexList[2]].position,
                    this.vertices[face.indexList[1]].position,
                    this.vertices[face.indexList[0]].position);
            colPolygons ~= poly;
        }
        return colPolygons;
    }
}
