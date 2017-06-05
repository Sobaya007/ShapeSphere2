module sbylib.primitive.Vertex;

import sbylib.primitive;
import sbylib.math;

import std.math, std.algorithm, std.array;

class Vertex {
    private {
        vec3 mPosition;
        vec3 mNormal = vec3(0);
        vec2 mTexcoord = vec2(0);
        vec3 mTransformedPosition;
        vec3 mTransformedNormal;
        bool mHasNormal;
        bool mHasTexcoord;
    }
    Face[] mParents;
    Primitive mPrimitive;

    this(vec3 p) {
        this.mPosition = p;
    }

    @property @nogc {
        vec3 Position(vec3 p) {
            return mPosition = p;
        }

        vec3 Normal(vec3 n) {
            mHasNormal = true;
            return mNormal = n;
        }

        vec2 Texcoord(vec2 t) {
            mHasTexcoord = true;
            return mTexcoord = t;
        }

        //only access from Primitive.cache()
        package {
            vec3 TransformedPosition(vec3 p) {
                return mTransformedPosition = p;
            }

            vec3 TransformedNormal(vec3 n) {
                return mTransformedNormal = n;
            }
        }

        vec3 Position() {
            return mPosition;
        }

        vec3 Normal() {
            return mNormal;
        }

        vec2 Texcoord() {
            return mTexcoord;
        }

        //NOTE: This method runs correctly after calling Primitive.cache()
        vec3 TransformedPosition() {
            return mTransformedPosition;
        }

        vec3 TransformedNormal() {
            return mTransformedNormal;
        }
    }

    bool hasNormal() {
        return mHasNormal;
    }

    bool hasTexcoord() {
        return mHasTexcoord;
    }

    Vertex dup() {
        Vertex v = new Vertex(Position);
        v.mNormal = mNormal;
        v.mTexcoord = mTexcoord;
        v.mHasNormal = mHasNormal;
        v.mHasTexcoord = mHasTexcoord;
        return v;
    }
}

class VertexList {
    private {
        Vertex[] mVertexList;
    }

    this(Vertex[] vertexList) {
        this.mVertexList = vertexList;
    }

    this(vec3[] vertexList) {
        this(vertexList.map!(a => new Vertex(a)).array);
    }

    void setPositionList(vec3[] posList) @nogc {
        assert(posList.length == mVertexList.length);
        foreach (i; 0..posList.length) {
            mVertexList[i].Position = posList[i];
        }
    }

    void getPositionList(vec3[] positionList) {
        foreach (i; 0..mVertexList.length) {
            positionList[i] = mVertexList[i].Position;
        }
    }

    void getNormalList(vec3[] normalList) {
        assert(hasNormal());
        foreach (i; 0..mVertexList.length) {
            normalList[i] = mVertexList[i].Normal;
        }
    }

    void getTexcoordList(vec2[] texcoordList) {
        assert(hasTexcoord());
        foreach (i; 0..mVertexList.length) {
            texcoordList[i] = mVertexList[i].Texcoord;
        }
    }

    void getTransformedPositionList(vec3[] positionList) {
        foreach (i; 0..mVertexList.length) {
            positionList[i] = mVertexList[i].TransformedPosition;
        }
    }

    void getTransformedNormalList(vec3[] normalList) {
        foreach (i; 0..mVertexList.length) {
            normalList[i] = mVertexList[i].TransformedNormal;
        }
    }

    bool hasNormal() {
        return mVertexList[0].hasNormal;
    }

    bool hasTexcoord() {
        return mVertexList[0].hasTexcoord;
    }

    size_t length() {
        return mVertexList.length;
    }

    Vertex opIndex(size_t index) {
        return mVertexList[index];
    }

    int opApply(int delegate(ref Vertex) dg) {
        int result = 0;
        foreach (v; mVertexList) {
            result = dg(v);
            if (result) break;
        }
        return result;
    }

}
