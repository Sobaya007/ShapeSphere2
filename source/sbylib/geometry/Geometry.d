module sbylib.geometry.Geometry;

import sbylib.gl.Constants;
import sbylib.gl.VertexArray;
import sbylib.gl.BufferObject;
import sbylib.gl.Attribute;
import sbylib.geometry.Vertex;
import sbylib.geometry.Face;
import sbylib.material.Material;
import sbylib.utils.Functions;

import std.range;
import std.algorithm;
import std.array;
import std.typecons;

interface Geometry {
    void render(Material material);
}

static string[] getNames(Attribute[] attrs) {
    string[] res;
    foreach (attr; attrs) {
        res ~= attr.name;
    }
    return res;
}

class GeometryTemp(Attribute[] Attributes, Prim Mode) : Geometry{
    alias VertexA = Vertex!(Attributes);

    VertexA[] vertices;
    Face[] faces;
    IndexBuffer ibo;
    Tuple!(Attribute, VertexBuffer)[] buffers;

    this(VertexA[] vertices, Face[] faces) {
        this.vertices = vertices;
        this.faces = faces;
        foreach (attr; Range!(Attribute, Attributes)) {
            auto buffer = new VertexBuffer;
            buffer.sendData(vertices.map!(vertex => __traits(getMember, vertex, attr.name).elements).reduce!((a,b) => a ~ b), BufferUsage.Static);
            buffers ~= tuple(attr, buffer);
        }
        this.ibo = new IndexBuffer;
        ibo.sendData(faces.map!(face => face.indexList).join, BufferUsage.Static);
    }

    override void render(Material material) {
        material.set(this.buffers);
    }
}
