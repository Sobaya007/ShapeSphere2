module sbylib.geometry.Box;

import sbylib.geometry.Geometry;
import sbylib.geometry.GeometryUtil;
import sbylib.geometry.Face;
import sbylib.geometry.Vertex;
import sbylib.math.Vector;
import sbylib.wrapper.gl.Constants;
import sbylib.wrapper.gl.Attribute;

import std.algorithm;
import std.array;
import std.range;

class Box {

    private static Geometry geom;

    private this()  {
    }

    public static Geometry get() {
        if (geom) return geom;
        return geom = create();
    }

    private static Geometry create(float width = 1, float height = 1, float depth = 1) {
        VertexNT[] vertices;
        foreach (i; 0..6) {
            const s = i % 2 ? +1 : -1;
            alias swap = (a, i) => vec3(a[(0+i)%3], a[(1+i)%3], a[(2+i)%3]);
            const positions = [
            vec3(+s, +s, +s),
            vec3(+s, +s, -s),
            vec3(+s, -s, +s),
            vec3(+s, -s, -s)
            ].map!(a => swap(a, i/2))
            .map!(a => a * 0.5).array;
            const normals = [
            vec3(+s,0,0),
            vec3(+s,0,0),
            vec3(+s,0,0),
            vec3(+s,0,0)
            ].map!(a => swap(a, i/2)).array;
            const uvs = [
            vec2(0,0),
            vec2(0,1),
            vec2(1,0),
            vec2(1,1)
            ];
            foreach(j; [0,1,2,2,1,3]) {
                auto v = new VertexNT;
                v.position = positions[j];
                v.normal = normals[j];
                v.uv = uvs[j];
                vertices ~= v;
            }
        }
        uint[] indices = cast(uint[])iota(vertices.length).array;
        auto g = new GeometryTemp!([Attribute.Position, Attribute.Normal, Attribute.UV], Prim.Triangle)(vertices, indices);
        return g;
    }
}
