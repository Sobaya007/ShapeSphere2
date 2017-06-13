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

class Box {

    private static Geometry geom;

    private this()  {
    }

    public static Geometry get() {
        if (geom) return geom;
        return geom = create();
    }

    private static Geometry create(float width = 1, float height = 1, float depth = 1) {
        auto vertices = [
        vec3(+1,+1,+1),
        vec3(+1,-1,+1),
        vec3(-1,-1,+1),
        vec3(-1,+1,+1),
        ].map!(a => new Vertex!([Attribute(3, "normal")])(a)).array;
        uint[] indices = [0,1,2,3];
        auto g = new GeometryTemp!([Attribute(3, "normal")], Prim.TriangleFan)(vertices, indices);
        return g;
    }

}
