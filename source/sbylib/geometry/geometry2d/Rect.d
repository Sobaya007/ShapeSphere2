module sbylib.geometry.geometry2d.Rect;

import sbylib.math.Vector;
import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.wrapper.gl.Attribute;
import sbylib.wrapper.gl.Constants;
import std.algorithm;
import std.range;
import std.array;

alias GeometryRect = GeometryTemp!([Attribute.Position, Attribute.UV], Prim.TriangleFan);

class Rect {

    public static GeometryRect create(float width=0.5, float height = 0.5) {
        const positions = [
        vec3(-width/2, -height/2, 0),
        vec3(+width/2, -height/2, 0),
        vec3(+width/2, +height/2, 0),
        vec3(-width/2, +height/2, 0),
        ];
        const uvs = [
        vec2(0,0),
        vec2(1,0),
        vec2(1,1),
        vec2(0,1)
        ];
        auto indices = iota(4u).array;
        VertexT[] vertices;
        foreach(tuple; zip(positions, uvs)) {
            auto v = new VertexT(tuple.expand);
            vertices ~= v;
        }
        auto g = new GeometryRect(vertices, indices);
        return g;
    }
}
