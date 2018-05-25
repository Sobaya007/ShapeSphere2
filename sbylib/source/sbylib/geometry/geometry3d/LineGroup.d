module sbylib.geometry.geometry3d.LineGroup;

import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.wrapper.gl.Attribute;
import sbylib.wrapper.gl.Constants;
import sbylib.math.Vector;
import std.algorithm;
import std.range;

class LineGroup(Prim p) 
if (p == Prim.Line || p == Prim.LineStrip || p == Prim.LineLoop) {
    alias GeometryLineGroup = TypedGeometry!([Attribute.Position], p);

    static GeometryLineGroup create(uint size) {
        return create(iota(size).map!(_=>vec3(0)).array);
    }

    static GeometryLineGroup create(vec3[] input) {
        auto indices = iota(cast(uint)input.length).array;
        VertexP[] vertices;
        foreach (v; input) {
            vertices ~= new VertexP(v);
        }
        return new GeometryLineGroup(vertices, indices.idup);
    }
}

alias Lines = LineGroup!(Prim.Line);
alias LineStrip = LineGroup!(Prim.LineStrip);
alias LineLoop = LineGroup!(Prim.LineLoop);
