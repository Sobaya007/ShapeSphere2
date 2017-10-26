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
        auto vertices = (northern!(Geometry.VertexA)(radius, tCut, pCut) ~ southern!(Geometry.VertexA)(radius, tCut, pCut));
        auto indices = getNorthernIndices(tCut, pCut) ~ getSouthernIndices(tCut, pCut);
        auto g = new Geometry(vertices, indices);
        return g;
    }

    public static Vertex[] northern(Vertex=VertexNT)(float radius, uint tCut, uint pCut) out(res) {
        assert(res.length == 1 + tCut * pCut);
    } body {
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
            return VertexNT.create!Vertex(
                    vec * radius,
                    vec,
                    vec2(tp.t, tp.p*.5 + .5));
        }).array;
    }

    public static Vertex[] southern(Vertex=VertexNT)(float radius, uint tCut, uint pCut) out (res) {
        assert(res.length == 1 + tCut * pCut);
    } body {
        return northern(radius, tCut, pCut)
        .map!((v) {
            return VertexNT.create!Vertex(
                -v.position,
                -v.normal,
                vec2(.5 + v.uv.x, 1 - v.uv.y));
        }).array;
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
        import std.stdio;
        writeln(result.minElement);
        writeln(result.maxElement);
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
