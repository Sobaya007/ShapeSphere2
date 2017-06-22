module sbylib.geometry.geometry3d.Sphere;

import std.math;
import sbylib.geometry.Geometry;
import sbylib.geometry.Vertex;
import sbylib.math.Vector;
import sbylib.wrapper.gl.Attribute;

import std.algorithm;
import std.array;
import std.typecons;

class Sphere {

    private this(){}

    public static Geometry create(float radius = 0.5, uint level = 0) {
        auto vertexIndex = createVertexIndex(level);
        auto vertex = vertexIndex[0].map!((v) {
            VertexN res = new VertexN;
            res.position = v * radius;
            res.normal = v;
            return res;
        }).array;
        auto index = vertexIndex[1];
        auto g = new GeometryN(vertex, index);
        return g;
    }

    private static vec3[] original() {
        enum goldenRatio = (1 + sqrt(5.0f)) / 2;
        vec3[] vertex;
        vertex ~= vec3(-1, +goldenRatio, 0);
        vertex ~= vec3(+1, +goldenRatio, 0);
        vertex ~= vec3(-1, -goldenRatio, 0);
        vertex ~= vec3(+1, -goldenRatio, 0);

        vertex ~= vec3(0, -1, +goldenRatio);
        vertex ~= vec3(0, +1, +goldenRatio);
        vertex ~= vec3(0, -1, -goldenRatio);
        vertex ~= vec3(0, +1, -goldenRatio);

        vertex ~= vec3(+goldenRatio, 0, -1);
        vertex ~= vec3(+goldenRatio, 0, +1);
        vertex ~= vec3(-goldenRatio, 0, -1);
        vertex ~= vec3(-goldenRatio, 0, +1);
        return vertex.map!(v => normalize(v)).array;
    }

    private static uint[] originalIndex() {
        uint[] index = [
           0,  11,  5,
           0,   5,  1,
           0,   1,  7,
           0,   7, 10,
           0,  10, 11,

           1,   5,  9,
           5,  11,  4,
          11,  10,  2,
          10,   7,  6,
           7,   1,  8,

           3,   9,  4,
           3,   4,  2,
           3,   2,  6,
           3,   6,  8,
           3,   8,  9,

           4,   9,  5,
           2,   4, 11,
           6,   2, 10,
           8,   6,  7,
           9,   8,  1];
        return index;
    }

    private static Tuple!(vec3[], uint[]) createVertexIndex(uint level) {
        if (level == 0) {
            return tuple(original(), originalIndex());
        }
        auto before = createVertexIndex(level-1);
        auto vertex = before[0];
        auto index = before[1];
        int idx = cast(int)vertex.length;
        //解像度細かく
        uint[uint] cache;
        uint getMiddle(uint a, uint b) {
            uint pair = a < b ? (a * 114514 + b) : (b *	114514 + a);
            uint* r = pair in cache;
            if (r != null) {
                return *r;
            }
            auto newVertex = normalize(vertex[a] + vertex[b]);
            vertex ~= newVertex;
            cache[pair] = idx;
            return idx++;
        }

        uint[] index2;
        foreach (i; 0..index.length/3) { //各面について

            uint v0 = getMiddle(index[i*3+0],index[i*3+1]);
            uint v1 = getMiddle(index[i*3+1],index[i*3+2]);
            uint v2 = getMiddle(index[i*3+2],index[i*3+0]);

            index2 ~= [index[i*3+0], v0, v2];
            index2 ~= [v0, index[i*3+1], v1];
            index2 ~= [v2,v1,index[i*3+2]];
            index2 ~= [v0, v1, v2];
        }
        return tuple(vertex, index2);
    }

}
