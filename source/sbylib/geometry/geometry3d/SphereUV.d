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
    
    public static Geometry create(float radius = 0.5, uint tCut = 20, uint pCut = 20) {
        auto vertices = (northern(tCut, pCut) ~ southern(tCut, pCut))
        .map!((v) {
            v.position *= radius;
            return v;
        }).array;
        auto indices = getNorthernIndices(tCut, pCut) ~ getSouthernIndices(tCut, pCut);
        auto g = new GeometryNT(vertices, indices);
        return g;
    }

    private static VertexNT[] northern(uint tCut, uint pCut) {
        struct TP {float t; float p;}
        TP[] tps;
        tps ~= TP(0,1);
        foreach_reverse (i; 0..pCut) {
            auto p = cast(float)i / pCut;
            foreach (j; 0..tCut+1) {
                auto t = cast(float)j / tCut;
                tps ~= TP(t,p);
            }
        }
        return tps.map!((tp) {
            auto theta = tp.t * 2 * PI;
            auto phi = tp.p * PI / 2;
            auto vec = vec3(
                cos(phi) * cos(theta),
                sin(phi),
                cos(phi) * sin(theta));
            auto res = new VertexNT;
            res.position = vec;
            res.normal = vec;
            res.uv = vec2(tp.t, tp.p*.5 + .5);
            return res;
        }).array;
    }

    private static VertexNT[] southern(uint tCut, uint pCut) {
        return northern(tCut, pCut)
        .map!((v) {
            v.position = -v.position;
            v.normal = -v.normal;
            v.uv = vec2(.5 + v.uv.x, 1 - v.uv.y);
            return v;
        }).array;
    }

    private static uint[] getNorthernIndices(uint tCut, uint pCut) {
        uint[] result;
        foreach (i; 0..tCut+1) {
            result ~= [0, i+1, i+2];
        }
        foreach (i; 0..pCut) {
            auto ni = i+1;
            foreach (j; 0..tCut+1) {
                auto nj = j+1;
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
        return result;
    }

    private static uint[] getSouthernIndices(uint tCut, uint pCut) {
        return getNorthernIndices(tCut, pCut)
        .map!(idx => idx+(tCut+1)*pCut+1).array;
    }
}
