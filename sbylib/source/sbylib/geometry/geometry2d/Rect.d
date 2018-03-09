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

    enum OriginX {
        Left = -1,
        Center = 0,
        Right = 1
    }
    enum OriginY {
        Bottom = -1,
        Center = 0,
        Top = 1
    }

    public static GeometryRect create(float width=0.5, float height = 0.5, OriginX originX = OriginX.Center, OriginY originY = OriginY.Center) {
        vec3 center = vec3(
            -originX * (width/2),
            -originY * (height/2),
            0
        );
        const positions = [
            vec3(-width/2, -height/2, 0) + center,
            vec3(+width/2, -height/2, 0) + center,
            vec3(+width/2, +height/2, 0) + center,
            vec3(-width/2, +height/2, 0) + center,
        ];
        const uvs = [
        vec2(0,0),
        vec2(1,0),
        vec2(1,1),
        vec2(0,1)
        ];
        VertexT[] vertices;
        foreach(tuple; zip(positions, uvs)) {
            auto v = new VertexT(tuple.expand);
            vertices ~= v;
        }
        auto g = new GeometryRect(vertices);
        return g;
    }
}
