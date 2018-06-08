module sbylib.geometry.geometry3d.Dodecahedron;

import std.math, std.algorithm, std.array;
import sbylib.wrapper.gl.Attribute;
import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.math.Vector;


enum Attributes = [Attribute.Position, Attribute.Normal, Attribute.UV, Attribute(3, "_uv2")];
alias VertexDodecahedron = Vertex!(Attributes);
alias GeometryDodecahedron = TypedGeometry!(Attributes);

class Dodecahedron {

    private this(){}

    public static GeometryDodecahedron create(float radius = 0.5) {

        auto scale = radius * 4 / (sqrt(15.0) + sqrt(3.0));

        enum GOLDEN = (sqrt(5.0) - 1) / 2;
        enum GOLDEN_INV = 1 / GOLDEN;

        auto positions = [
            vec3(+1, +1, +1),
            vec3(+1, +1, -1),
            vec3(+1, -1, +1),
            vec3(+1, -1, -1),
            vec3(-1, +1, +1),
            vec3(-1, +1, -1),
            vec3(-1, -1, +1),
            vec3(-1, -1, -1),
            vec3(0, +GOLDEN_INV, +GOLDEN),
            vec3(0, +GOLDEN_INV, -GOLDEN),
            vec3(0, -GOLDEN_INV, +GOLDEN),
            vec3(0, -GOLDEN_INV, -GOLDEN),
            vec3(+GOLDEN_INV, +GOLDEN, 0), 
            vec3(+GOLDEN_INV, -GOLDEN, 0), 
            vec3(-GOLDEN_INV, +GOLDEN, 0), 
            vec3(-GOLDEN_INV, -GOLDEN, 0), 
            vec3(+GOLDEN, 0, +GOLDEN_INV), 
            vec3(-GOLDEN, 0, +GOLDEN_INV), 
            vec3(+GOLDEN, 0, -GOLDEN_INV), 
            vec3(-GOLDEN, 0, -GOLDEN_INV), 
        ];

        uint[] indices;
        indices ~= [0, 2, 13];
        indices ~= [0, 8, 16];
        indices ~= [0, 9, 8];
        indices ~= [0, 12, 9];
        indices ~= [0, 16, 2];
        indices ~= [0, 13, 12];
        indices ~= [1, 3, 18];
        indices ~= [1, 9, 12];
        indices ~= [1, 12, 13];
        indices ~= [1, 13, 3];
        indices ~= [1, 18, 9];
        indices ~= [2, 10, 13];
        indices ~= [2, 16, 17];
        indices ~= [2, 17, 10];
        indices ~= [3, 11, 18];
        indices ~= [3, 13, 11];
        indices ~= [4, 6, 17];
        indices ~= [4, 8, 14];
        indices ~= [4, 14, 15];
        indices ~= [4, 15, 6];
        indices ~= [4, 17, 8];
        indices ~= [5, 7, 15];
        indices ~= [5, 8, 9];
        indices ~= [5, 9, 19];
        indices ~= [5, 14, 8];
        indices ~= [5, 15, 14];
        indices ~= [5, 19, 7];
        indices ~= [6, 10, 17];
        indices ~= [6, 15, 10];
        indices ~= [7, 11, 15];
        indices ~= [7, 18, 11];
        indices ~= [7, 19, 18];
        indices ~= [8, 17, 16];
        indices ~= [9, 18, 19];
        indices ~= [10, 11, 13];
        indices ~= [10, 15, 11];

        return new GeometryDodecahedron(positions.map!(p => new VertexDodecahedron(p * scale, vec3(0,1,0), vec2(0,0), vec3(0,0,0))).array, indices.idup);
    }
}
