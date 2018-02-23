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
            getNorthernIndices(tCut, pCut)
          ~ getSouthernIndices(tCut, pCut)
          ~ getPoleIndices(tCut, pCut);
        return new GeometryNT(vertices, indices.idup);
    }

    public static GeometryCapsule create(float radius, vec3 start, vec3 end, uint tCut = 20, uint pCut = 20) {
        auto len = length(end - start);
        VertexNT[] vertices =
            northern(radius, len, tCut, pCut)
          ~ southern(radius, len, tCut, pCut);
        uint[] indices =
            getNorthernIndices(tCut, pCut)
          ~ getSouthernIndices(tCut, pCut)
          ~ getPoleIndices(tCut, pCut);
        auto c = (start + end) / 2;
        auto r = mat3.rotFromTo(vec3(0,1,0), normalize(end - start));
        foreach (ref v; vertices) {
            v.position = r * v.position + c;
        }
        return new GeometryNT(vertices, indices.idup);
    }

    private static VertexNT[] northern(float radius, float length, uint tCut, uint pCut) {
        struct TP {float t; float p;}
        TP[] tps;
        //T = [0, 1)
        //P = [0, 1]
        tps ~= TP(0,1);
        foreach_reverse (i; 0..pCut) {
            auto p = cast(float)i / pCut;
            foreach (j; 0..tCut) {
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
            return new VertexNT(
                    vec * radius + vec3(0,length/2,0),
                    vec,
                    vec2(tp.t, tp.p*.5 + .5));
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

    private static uint[] getPoleIndices(uint tCut, uint pCut) {
        uint[] result;
        uint nhead = tCut * (pCut-1);
        uint shead = 1 + tCut * (pCut * 2 - 1);
        foreach (i; 0..tCut) {
            auto j = (i+1) % tCut;
            result ~= nhead + i;
            result ~= shead + i;
            result ~= nhead + j;
            result ~= shead + i;
            result ~= nhead + j;
            result ~= shead + j;
        }
        return result;
    }

    public static uint[] getNorthernIndices(uint tCut, uint pCut) out (res) {
        assert(res.length == 3 * (tCut + (pCut-1) * tCut * 2));
        assert(res.minElement == 0);
        assert(res.maxElement == tCut * pCut);
    } body {
        uint[] result;
        foreach (i; 0..tCut) {
            result ~= [0, i+1, i+2];
        }
        foreach (i; 0..pCut-1) {
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
        return result;
    }

    public static uint[] getSouthernIndices(uint tCut, uint pCut) out (res) {
        assert(res.length == 3 * (tCut + (pCut-1) * tCut * 2));
        assert(res.minElement == tCut * pCut + 1);
        assert(res.maxElement == tCut * pCut * 2 + 1);
    } body {
        uint[] result;
        foreach (i; 0..tCut) {
            result ~= [0, i+2, i+1];
        }
        foreach (i; 0..pCut-1) {
            auto ni = i+1; //[1, pCut]
            foreach (j; 0..tCut) {
                auto nj = (j+1) % tCut; //[0, tCut-1]
                result ~= [
                1 +  j +  i * tCut,
                1 + nj + ni * tCut,
                1 +  j + ni * tCut
                ];
                result ~= [
                1 + nj + ni * tCut,
                1 +  j +  i * tCut,
                1 + nj +  i * tCut
                ];
            }
        }
        return result.map!(r => r + tCut*pCut+1).array;
    }
}
