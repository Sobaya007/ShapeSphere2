module sbylib.geometry.geometry3d.Line;

import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.wrapper.gl.Attribute;
import sbylib.wrapper.gl.Constants;
import sbylib.math.Vector;

import std.range;
import std.algorithm;

alias GeometryLine = GeometryTemp!([Attribute.Position, Attribute.UV], Prim.Line);

class Line {

    static GeometryLine create(vec3 s, vec3 e) {
        auto positions = [s, e];
        auto uvs = [vec2(0), vec2(1)];
        auto indices = iota(2u).array;
        VertexT[] vertices;
        foreach (tuple; zip(positions, uvs)) {
            vertices ~= new VertexT(tuple.expand);
        }
        return new GeometryLine(vertices, indices);
    }
}
