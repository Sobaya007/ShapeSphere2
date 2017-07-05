module sbylib.geometry.geometry3d.Capsule;

import std.math;
import std.algorithm;
import std.array;
import sbylib.math;
import sbylib.geometry.Geometry;
import sbylib.geometry.geometry3d.SphereUV;
import sbylib.geometry.Vertex;

alias GeometryCapsule = GeometryNT;

class Capsule {

    private this() {}

    public static GeometryCapsule create(float radius, float length, uint tCut = 20, uint pCut = 20) {
        VertexNT[] vertices =
            northern(radius, length, tCut, pCut)
          ~ southern(radius, length, tCut, pCut);
        uint[] indices =
            SphereUV.getNorthernIndices(tCut, pCut)
          ~ SphereUV.getSouthernIndices(tCut, pCut)
          ~ getPollIndices(tCut, pCut);
        return new GeometryNT(vertices, indices);
    }

    private static VertexNT[] northern(float radius, float length, uint tCut, uint pCut) {
       return SphereUV.northern(radius, tCut, pCut)
        .map!((v) {
            v.position.y += length / 2;
            return v;
        }).array;
    }

    private static VertexNT[] southern(float radius, float length, uint tCut, uint pCut) {
       return northern(radius, length, tCut, pCut)
        .map!((v) {
            v.position.y = -v.position.y;
            v.normal.y = -v.normal.y;
            v.uv = vec2(.5 + v.uv.x, 1 - v.uv.y);
            return v;
        }).array;
    }

    private static uint[] getPollIndices(uint tCut, uint pCut) {
        uint[] result;
        uint nhead = 1 + (tCut+1) * (pCut-1);
        uint shead = nhead + 1 + (tCut+1) * (pCut-1);
        foreach (i; 0..tCut) {
            result ~= nhead + i;
            result ~= shead + i;
            result ~= nhead + i+1;
            result ~= shead + i;
            result ~= nhead + i+1;
            result ~= shead + i+1;
        }
        return result;
    }
}
