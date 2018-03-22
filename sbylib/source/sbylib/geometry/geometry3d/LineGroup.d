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
        auto indices = iota(size).array;
        VertexP[] vertices;
        foreach (i; 0..size) {
            vertices ~= new VertexP(vec3(0));
        }
        return new GeometryLineGroup(vertices, indices.idup);
    }
}

alias Lines = LineGroup!(Prim.Line);
alias LineStrip = LineGroup!(Prim.LineStrip);
alias LineLoop = LineGroup!(Prim.LineLoop);
