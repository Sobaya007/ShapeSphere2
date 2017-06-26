module sbylib.geometry.geometry3d.Plane;

import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.math.Vector;

class Plane {

    private this() {}

    public static GeometryNT create(float width = 1, float height = 1) {
        VertexNT[] vertices;
        vertices ~= new VertexNT(vec3(-width/2, 0, -height/2), vec3(0,1,0), vec2(0,0));
        vertices ~= new VertexNT(vec3(+width/2, 0, -height/2), vec3(0,1,0), vec2(1,0));
        vertices ~= new VertexNT(vec3(-width/2, 0, +height/2), vec3(0,1,0), vec2(0,1));
        vertices ~= new VertexNT(vec3(+width/2, 0, +height/2), vec3(0,1,0), vec2(1,1));
        return new GeometryNT(vertices, [0,1,2,3]);
    }
}
