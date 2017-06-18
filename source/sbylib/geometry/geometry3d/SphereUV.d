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
        auto g = new GeometryTemp!([Attribute.Position, Attribute.Normal])(vertices, indices);
        return g;
    }

    private static VertexN[] northern(uint tCut, uint pCut) {
        vec3[] result;
        result ~= vec3(0,1,0);
        foreach_reverse (i; 0..pCut) {
            auto phi = i * PI / (2 * pCut);
            foreach (j; 0..tCut) {
                auto theta = j * 2 * PI / tCut;
                result ~= vec3(
                         cos(phi) * cos(theta),
                         sin(phi),
                         cos(phi) * sin(theta)
                );
            }
        }
        return result.map!((v) {
            VertexN res = new VertexN;
            res.position = v;
            res.normal = v;
            return res;
        }).array;
    }

    private static VertexN[] southern(uint tCut, uint pCut) {
        return northern(tCut, pCut)
        .map!((v) {
            v.position = -v.position;
            v.normal = -v.normal;
            return v;
        }).array;
    }

    private static uint[] getNorthernIndices(uint tCut, uint pCut) {
        uint[] result;
        foreach (i; 0..tCut) {
            result ~= [0, i+1, (i+1) % tCut + 1];
        }
        foreach (i; 0..pCut-1) {
            auto ni = i+1;
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

    private static uint[] getSouthernIndices(uint tCut, uint pCut) {
        return getNorthernIndices(tCut, pCut)
        .map!(idx => idx+pCut*tCut+1).array;
    }

//    static uint[][] getIndices(uint tCut, uint pCut) {
//        //側面
//        foreach (i; 0..tCut) {
//            result ~= [
//            (pCut-1) * tCut + 1 + i,
//            (2*pCut-2) * tCut + 2 + i + tCut / 2,
//                (2*pCut-2) * tCut + 2 + (i+1) % tCut + tCut / 2,
//                (pCut-1) * tCut + 1 + (i+1) % tCut,
//                ];
//        }
//        return result;
//    }
}
