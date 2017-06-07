module sbylib.geometry.Geometry;

import sbylib.gl.Constants;
import sbylib.gl.VertexArray;

interface IGeometry {
}

class Geometry(string[] Attributes, Prim Mode) : IGeometry{
    alias VertexA = Vertex!(Attributes);

    immutable {
        VertexA[] vertices;
        Face[] faces;
    }

    this(VertexA[] vertices, Face[] faces) {
        this.vertices = vertices;
        this.faces = faces;
    }

    override VAO generateVAO() {

    }
}

private static string[] getTypes(string[] attr) {
    assert(attr.length % 2 == 0);
    string[] types;
    foreach (i; 0..attr.length/2) {
        types ~= attr[i*2];
    }
    return types;
}

private static string[] getNames(string[] attr) {
    assert(attr.length % 2 == 0);
    string[] names;
    foreach (i; 0..attr.length/2) {
        names ~= attr[i*2+1];
    }
    return names;
}
