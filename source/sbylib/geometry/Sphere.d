module sbylib.geometry.Sphere;

import derelict.opengl;

import std.math;

import sbylib.geometry;
import sbylib.math;
import sbylib.gl;
import sbylib.shadertemplates;

//class Sphere : Geometry {
//
//    private static {
//        vec3[][] vertices;
//        uint[][][] indices;
//    }
//
//    private {
//        float mRadius;
//    }
//
//    this(float radius = 1, ShaderProgram shader = null)  {
//        if (shader is null) shader = ShaderStore.getShader("NormalShow");
//        this.mRadius = radius;
//        enum level = 2;
//        VertexList vList = new VertexList(getVertices(level));
//        FaceList fList = new FaceList(getIndices(level), Face.Type.TriangleFan);
//        fList.setVertexList(vList);
//        fList.generateSmoothNormal;
//        super(fList, shader);
//    }
//
//    this(ShaderProgram shader){
//        this(1, shader);
//    }
//
//    @property @nogc {
//        float Radius(float radius) {
//            return mRadius = radius;
//        }
//
//        float Radius() {
//            return mRadius;
//        }
//    }
//
//    override {
//        mat4 getWorldMatrix() {
//            return super.getWorldMatrix * mat4.scale(vec3(Radius));
//        }
//    }
//
//    static vec3[] getVertices(uint recursionLevel) {
//        if (vertices.length <= recursionLevel) create(recursionLevel);
//        return vertices[recursionLevel].dup;
//    }
//
//    static uint[][] getIndices(uint recursionLevel) {
//        if (indices.length <= recursionLevel) create(recursionLevel);
//        return indices[recursionLevel].dup;
//    }
//
//    static this() {
//        enum goldenRatio = (1 + sqrt(5.0f)) / 2;
//
//        vec3[] vertex;
//
//        vertex ~= vec3(-1, +goldenRatio, 0);
//        vertex ~= vec3(+1, +goldenRatio, 0);
//        vertex ~= vec3(-1, -goldenRatio, 0);
//        vertex ~= vec3(+1, -goldenRatio, 0);
//
//        vertex ~= vec3(0, -1, +goldenRatio);
//        vertex ~= vec3(0, +1, +goldenRatio);
//        vertex ~= vec3(0, -1, -goldenRatio);
//        vertex ~= vec3(0, +1, -goldenRatio);
//
//        vertex ~= vec3(+goldenRatio, 0, -1);
//        vertex ~= vec3(+goldenRatio, 0, +1);
//        vertex ~= vec3(-goldenRatio, 0, -1);
//        vertex ~= vec3(-goldenRatio, 0, +1);
//
//        foreach (i; 0..vertex.length) vertex[i] = normalize(vertex[i]);
//
//        vertices ~= vertex;
//
//        uint[][] index;
//        index ~= [  0,  11,  5];
//        index ~= [  0,   5,  1];
//        index ~= [  0,   1,  7];
//        index ~= [  0,   7, 10];
//        index ~= [  0,  10, 11];
//
//        index ~= [  1,   5,  9];
//        index ~= [  5,  11,  4];
//        index ~= [ 11,  10,  2];
//        index ~= [ 10,   7,  6];
//        index ~= [  7,   1,  8];
//
//        index ~= [  3,   9,  4];
//        index ~= [  3,   4,  2];
//        index ~= [  3,   2,  6];
//        index ~= [  3,   6,  8];
//        index ~= [  3,   8,  9];
//
//        index ~= [  4,   9,  5];
//        index ~= [  2,   4, 11];
//        index ~= [  6,   2, 10];
//        index ~= [  8,   6,  7];
//        index ~= [  9,   8,  1];
//
//        indices ~= index;
//    }
//
//    private static void create(uint recursionLevel) {
//
//        auto vertex = getVertices(recursionLevel-1);
//        auto index = getIndices(recursionLevel-1);
//
//        int idx = cast(int)vertex.length;
//        //解像度細かく
//        uint[uint] cache;
//        uint getMiddle(uint a, uint b) {
//            uint pair = a < b ? (a * 114514 + b) : (b *	114514 + a);
//            uint* r = pair in cache;
//            if (r != null) {
//                return *r;
//            }
//            auto newVertex = normalize(vertex[a] + vertex[b]);
//            vertex ~= newVertex;
//            cache[pair] = idx;
//            return idx++;
//        }
//
//        uint[][] index2;
//        foreach (i; 0..index.length) { //各面について
//
//            uint v0 = getMiddle(index[i][0],index[i][1]);
//            uint v1 = getMiddle(index[i][1],index[i][2]);
//            uint v2 = getMiddle(index[i][2],index[i][0]);
//
//            index2 ~= [index[i][0], v0, v2];
//            index2 ~= [v0, index[i][1], v1];
//            index2 ~= [v2,v1,index[i][2]];
//            index2 ~= [v0, v1, v2];
//        }
//
//        vertices ~= vertex;
//        indices ~= index2;
//    }
//
//}
