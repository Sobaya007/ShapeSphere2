module sbylib.geometry.geometry3d.Plane;

import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.math.Vector;
import sbylib.wrapper.gl.Attribute;
import sbylib.wrapper.gl.Constants;

alias GeometryPlane = TypedGeometry!([Attribute.Position, Attribute.Normal, Attribute.UV], Prim.TriangleStrip);

class Plane {

    private this() {}

    public static GeometryPlane create(float width = 1, float height = 1) {
        VertexNT[] vertices;
        vertices ~= new VertexNT(vec3(-width/2, 0, -height/2), vec3(0,1,0), vec2(0,0));
        vertices ~= new VertexNT(vec3(+width/2, 0, -height/2), vec3(0,1,0), vec2(1,0));
        vertices ~= new VertexNT(vec3(-width/2, 0, +height/2), vec3(0,1,0), vec2(0,1));
        vertices ~= new VertexNT(vec3(+width/2, 0, +height/2), vec3(0,1,0), vec2(1,1));
        return new GeometryPlane(vertices, [2,1,0,3,2,1]);
    }

    public static GeometryPlane create(vec3 base1, vec3 base2) {
        VertexNT[] vertices;
        vertices ~= new VertexNT(-base1 -base2, vec3(0,1,0), vec2(0,0));
        vertices ~= new VertexNT(+base1 -base2, vec3(0,1,0), vec2(1,0));
        vertices ~= new VertexNT(-base1 +base2, vec3(0,1,0), vec2(0,1));
        vertices ~= new VertexNT(+base1 +base2, vec3(0,1,0), vec2(1,1));
        return new GeometryPlane(vertices, [2,1,0,3,2,1]);
    }
}
