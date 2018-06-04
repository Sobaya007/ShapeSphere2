module sbylib.geometry.geometry3d.LineGroup;

import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.wrapper.gl.Attribute;
import sbylib.wrapper.gl.Constants;
import sbylib.math.Vector;
import std.algorithm;
import std.range;
import sbylib.utils.Functions : Singleton;

class LineBuilder {
    mixin Singleton;

    private vec3[] vertices;
    private vec3 current;
    
    void beginPath() {
        vertices = [];
        current = vec3(0);
    }

    void moveTo(vec3 pos) {
        current = pos;
    }

    void moveTo(vec2 pos) {
        moveTo(vec3(pos, 0));
    }

    void lineTo(vec3 pos) {
        vertices ~= current;
        vertices ~= pos;
        current = pos;
    }

    void lineTo(vec2 pos) {
        lineTo(vec3(pos, 0));
    }

    void endPath() {
    }

    auto build() {
        return Lines.create(vertices);
    }
}

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
