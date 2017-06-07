module sbylib.geometry.Geometry;

import sbylib.gl.Constants;
import sbylib.gl.VertexArray;
import sbylib.gl.BufferObject;
import sbylib.gl.Attribute;
import sbylib.geometry.Vertex;
import sbylib.geometry.Face;
import sbylib.utils.Functions;

import std.range;
import std.algorithm;
import std.array;
import std.typecons;

interface IGeometry {
    Tuple!(Attribute, BufferObject)[] getBuffers();
}

static string[] getNames(Attribute[] attrs) {
    string[] res;
    foreach (attr; attrs) {
        res ~= attr.name;
    }
    return res;
}

class Geometry(Attribute[] Attributes, Prim Mode) : IGeometry{
    alias VertexA = Vertex!(Attributes);

    VertexA[] vertices;
    Face[] faces;
    BufferObject ibo;
    Tuple!(Attribute, BufferObject)[] buffers;

    this(VertexA[] vertices, Face[] faces) {
        this.vertices = vertices;
        this.faces = faces;
        foreach (attr; Range!(Attribute, Attributes)) {
            auto buffer = new BufferObject(BufferType.Array);
            buffer.sendData(vertices.map!(vertex => __traits(getMember, vertex, attr.name)).array, BufferUsage.Static);
            buffers ~= tuple(attr, buffer);
        }
        this.ibo = new BufferObject(BufferType.ElementArray);
        ibo.sendData(faces.map!(face => face.indexList).join, BufferUsage.Static);
    }

    override Tuple!(Attribute, BufferObject)[] getBuffers() {
        return this.buffers;
    }
}
