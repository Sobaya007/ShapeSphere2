module sbylib.geometry.geometry3d.SphereUV;

import std.math;
import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.math.Vector;
import sbylib.wrapper.gl.Attribute;

import std.algorithm;
import std.array;
import std.range;

class SphereUV {

    private this() {}

    public static Geometry create(Geometry=GeometryNT)(float radius = 0.5, uint tCut = 20, uint pCut = 20) {
        auto vertices = getVertices!(Geometry.VertexA)(radius, tCut, pCut);
        auto indices = getIndices(tCut, pCut);
        auto g = new Geometry(vertices, indices.idup);
        return g;
    }

    public static Vertex[] getVertices(Vertex=VertexNT)(float radius, uint tCut, uint pCut)
        out(res; res.length == (pCut*2-1) * tCut + 2)
    {
        struct TP {float t; float p;}
        TP[] tps;
        //T = [0, 1)
        //P = [-1, 1]
        tps ~= TP(0,1);
        foreach_reverse (i; 1..pCut*2) {
            auto p = cast(float)i / pCut - 1;
            foreach (j; 0..tCut) {
                auto t = cast(float)j / tCut;
                tps ~= TP(t,p);
            }
        }
        tps ~= TP(0,-1);
        return tps.map!((tp) {
            auto theta = tp.t * 2 * PI;
            auto phi = tp.p * PI / 2;
            auto vec = vec3(
                cos(phi) * cos(theta),
                sin(phi),
                cos(phi) * sin(theta));
            return VertexNT.create!Vertex(
                    vec * radius,
                    vec,
                    vec2(tp.t, tp.p*.5 + .5));
        }).array;
    }

    public static uint[] getIndices(uint tCut, uint pCut)
        out(res; res.length == 3 * ((2*pCut-1) * tCut * 2))
        out(res; res.minElement == 0)
        out(res; res.maxElement == (pCut*2-1) * tCut + 1)
    {
        uint[] result;
        foreach (i; 0..tCut) {
            result ~= [0, i+1, i+2];
        }
        foreach (i; 0..2*pCut-2) {
            auto ni = i+1; //[1, pCut]
            foreach (j; 0..tCut) {
                auto nj = (j+1) % tCut;
                result ~= [
                1 +  j +  i * tCut,
                1 +  j + ni * tCut,
                1 + nj + ni * tCut
                ];
                result ~= [
                1 + nj + ni * tCut,
                1 + nj +  i * tCut,
                1 +  j +  i * tCut
                ];
            }
        }
        auto last = (pCut*2-1) * tCut + 1;
        foreach (i; 0..tCut) {
            result ~= [last, last - tCut + i - 1, last - tCut + i];
        }
        return result;
    }
}
