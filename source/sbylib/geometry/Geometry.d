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

import std.range;
import std.algorithm;
import std.array;
import std.typecons;

interface Geometry {
    void render(VertexArray vao);
    Tuple!(Attribute, VertexBuffer)[] getBuffers();
    IndexBuffer getIndexBuffer();
}

class GeometryTemp(Attribute[] Attributes, Prim Mode) : Geometry{
    alias VertexA = Vertex!(Attributes);

    const VertexA[] vertices;
    const Face[] faces;
    const uint indicesCount;
    private IndexBuffer ibo;
    private Tuple!(Attribute, VertexBuffer)[] buffers;

    this(VertexA[] vertices, uint[] indices) {
        this.vertices = vertices;
        foreach (attr; Range!(Attribute, Attributes)) {
            auto buffer = new VertexBuffer;
            buffer.sendData(vertices.map!(vertex => __traits(getMember, vertex, attr.name).array).reduce!((a,b) => a ~ b), BufferUsage.Static);
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
            faces = [];
            break;
        }
        this.faces = faces;
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
}
