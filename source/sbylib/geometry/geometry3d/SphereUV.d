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

    public static Vertex[] northern(Vertex=VertexNT)(float radius, uint tCut, uint pCut) {
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
            return VertexNT.create!Vertex(
                    vec * radius,
                    vec,
                    vec2(tp.t, tp.p*.5 + .5));
        }).array;
    }

    public static Vertex[] southern(Vertex=VertexNT)(float radius, uint tCut, uint pCut) {
        return northern(radius, tCut, pCut)
        .map!((v) {
            return VertexNT.create!Vertex(
                -v.position,
                -v.normal,
                vec2(.5 + v.uv.x, 1 - v.uv.y));
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
