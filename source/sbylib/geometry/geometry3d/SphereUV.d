module sbylib.geometry.geometry3d.SphereUV;

import std.math;
import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.math.Vector;
import sbylib.wrapper.gl.Attribute;

import std.algorithm;
import std.array;
import std.range;

alias GeometrySphereUV = GeometryNT;

class SphereUV {

    private this() {}
    
    public static GeometrySphereUV create(float radius = 0.5, uint tCut = 20, uint pCut = 20) {
        auto vertices = (northern(radius, tCut, pCut) ~ southern(radius, tCut, pCut));
        auto indices = getNorthernIndices(tCut, pCut) ~ getSouthernIndices(tCut, pCut);
        auto g = new GeometryNT(vertices, indices);
        return g;
    }

    public static VertexNT[] northern(float radius, uint tCut, uint pCut) {
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
            res.position = vec * radius;
            res.normal = vec;
            res.uv = vec2(tp.t, tp.p*.5 + .5);
            return res;
        }).array;
    }

    public static VertexNT[] southern(float radius, uint tCut, uint pCut) {
        return northern(radius, tCut, pCut)
        .map!((v) {
            v.position = -v.position;
            v.normal = -v.normal;
            v.uv = vec2(.5 + v.uv.x, 1 - v.uv.y);
            return v;
        }).array;
    }

    public static uint[] getNorthernIndices(uint tCut, uint pCut) {
        uint[] result;
        foreach (i; 0..tCut+1) {
            result ~= [0, i+1, i+2];
        }
        foreach (i; 0..pCut) {
            auto ni = i+1;
            foreach (j; 0..tCut+1) {
                auto nj = (j+1) % (tCut + 1);
                result ~= [
                0 +  j +  i * tCut,
                0 +  j + ni * tCut,
                0 + nj + ni * tCut
                ];
                result ~= [
                0 + nj + ni * tCut,
                0 + nj +  i * tCut,
                0 +  j +  i * tCut
                ];
            }
        }
        return result;
    }

    public static uint[] getSouthernIndices(uint tCut, uint pCut) {
        return getNorthernIndices(tCut, pCut)
        .map!(idx => idx+(tCut+1)*pCut+1).array;
    }
}
