module sbylib.geometry.geometry3d.Pole;

import std.math;
import std.algorithm;
import std.array;
import sbylib.math.Vector;
import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;

alias GeometryPole = GeometryN;

class Pole {

    private this() {}

    public static GeometryPole create(float radius, float length, uint cut = 20) {

        VertexN[] vertices;
        vertices ~=
            (northCap(radius, length, cut) ~ southCap(radius, length, cut));
        uint[] indices =
            getSideIndices(cut)
          ~ getNorthernIndices(cut)
          ~ getSouthernIndices(cut);
        return new GeometryN(vertices, indices.idup);
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

    private static uint[] getSideIndices(uint cut) {
        uint[] result;
        foreach (i; 0..cut) {
            result ~= i + cut;
            result ~= i;
            result ~= (i+1) % cut;
            result ~= i + cut;
            result ~= (i+1) % cut;
            result ~= (i+1) % cut + cut;
        }
        return result;
    }

    private static uint[] getNorthernIndices(uint cut) {
        uint[] result;
        foreach(i; 1..cut-1) {
            result ~= 0;
            result ~= i+1;
            result ~= i;
        }
        return result;
    }

    private static uint[] getSouthernIndices(uint cut) {
        uint[] result;
        foreach(i; 1..cut-1) {
            result ~= 0 + cut;
            result ~= i + cut;
            result ~= i+1 + cut;
        }
        return result;
    }
}
