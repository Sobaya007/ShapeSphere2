module sbylib.geometry.geometry3d.Poll;

import std.math;
import std.algorithm;
import std.array;
import sbylib.math.Vector;
import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;

class Poll {

    private this() {}

    public static Geometry create(float radius, float length, uint cut = 20) {

        VertexN[] vertices;
        vertices ~= 
            (northCap(radius, length, cut) ~ southCap(radius, length, cut));
        return new GeometryN(vertices, getIndices(cut));
    }

    private static VertexN[] northCap(float radius, float length, uint cut) {
        VertexN[] result;
        foreach (i; 0..cut) {
            float t = cast(float)i / cut;
            float angle = t * PI * 2;
            VertexN v = new VertexN;
            v.position = vec3(cos(angle) * radius, length/2, sin(angle) * radius);
            v.normal = vec3(cos(angle),0,sin(angle));
            result ~= v;
        }
        return result;
    }

    private static VertexN[] southCap(float radius, float length, uint cut) {
        return northCap(radius, length, cut)
        .map!((v) {
            v.position.y = -v.position.y;
            return v;
        }).array;
    }

    private static uint[] getIndices(uint cut) {
        uint[] result;
        foreach (i; 0..cut) {
            result ~= i;
            result ~= i + cut;
            result ~= (i+1) % cut;
            result ~= i + cut;
            result ~= (i+1) % cut;
            result ~= (i+1) % cut + cut;
        }
        return result;
    }
}
