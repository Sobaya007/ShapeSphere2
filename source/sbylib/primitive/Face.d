module sbylib.primitive.Face;

import std.conv, std.algorithm, std.math, std.array;

import sbylib.primitive;
import sbylib.math;

class Face {

    enum Type {
        Triangles,
        TriangleStrip,
        TriangleFan
    }

    private {
        uint[] mOrdinalIndexList;
        uint[] mExpandedIndexList;
        Type mType;
        Vertex[] mChildren;
        Vertex[] mOrdinalChildren;
        vec3 mTransformedNormal;
    }

    this (uint[] indexList, Type type) {
        assert(indexList.length >= 3, "cannot create a face from " ~ indexList.length.to!string ~ "points.");
        this.mType = type;
        this.mOrdinalIndexList = indexList;

        final switch (mType) {
        case Type.Triangles:
            this.mExpandedIndexList = indexList;
            break;
        case Type.TriangleStrip:
            foreach (i; 0..indexList.length-2) {
                mExpandedIndexList ~= [indexList[i], indexList[i+1], indexList[i+2]];
            }
            break;
        case Type.TriangleFan:
            foreach (i; 1..indexList.length-1) {
                mExpandedIndexList ~= [indexList[0], indexList[i], indexList[i+1]];
            }
            break;
        }
    }

    static vec3 computeNormal(vec3[] vertex) {
        enum eps = 0.01;
        alias epsEql = (a,b) => (a-b).lengthSq < eps;
        assert(vertex.length >= 3);
        alias v = vertex;
        auto n = cross(v[2] - v[1], v[0] - v[1]).normalize;
        if (n.hasNaN) {
            //XXX: ここに来るの、ほんとはダメ。
            if (epsEql(v[0], v[1]) && epsEql(v[1], v[2])) {
                return vec3(0,1,0);
            }
            vec3 vec;
            if (epsEql(v[0], v[1])) {
                vec = v[2] - v[0];
            } else if (epsEql(v[1], v[2])) {
                vec = v[0] - v[1];
            } else if (epsEql(v[2], v[0])) {
                vec = v[1] - v[2];
            } else {
                assert(false); //ここに来るとほんとに意味わからん
            }
            n = vec.cross(vec3(1,0,0)).normalize;
            if (n.hasNaN) return vec.cross(vec3(0,1,0)).normalize;
            return n;
        }
        return n;
    }

    //not transformed
    vec3 computeNormal() out (n) {
        assert(n.hasNaN == false);
    } body {
        return Face.computeNormal(mChildren.map!(a => a.Position).array);
    }

    vec3 computeCenter() {
        assert(mChildren.length > 0);
        return mChildren.map!(v => v.Position).sum / mChildren.length;
    }

    @property @nogc {
        uint[] IndexList() {
            return mExpandedIndexList;
        }

        vec3 TransformedNormal(vec3 n) {
            return mTransformedNormal = n;
        }

        vec3 TransformedNormal() {
            return mTransformedNormal;
        }
    }

    Type getType() @nogc {
        return mType;
    }

    package {
        void associateVertices(VertexList vList) {
            mChildren = IndexList.map!(index => vList[index]).array;
            mChildren.each!(v => v.mParents ~= this);
            mOrdinalChildren = mOrdinalIndexList.map!(index => vList[index]).array;
        }
    }

    Vertex[] getChildren() {
        return mChildren;
    }

    Vertex[] getOrdinalChildren() @nogc {
        return mOrdinalChildren;
    }

}

class FaceList {
    private {
        Face[] mFaceList;
        VertexList mVertexList;
    }

    this(Face[] faceList) {
        this.mFaceList = faceList;
    }

    this(uint[][] faceList, Face.Type type) {
        foreach (face; faceList) {
            mFaceList ~= new Face(face, type);
        }
    }

    auto length() @nogc {
        return mFaceList.length;
    }

    Face opIndex(size_t index) @nogc {
        return mFaceList[index];
    }

    int opApply(int delegate(ref Face) dg) {
        int result = 0;
        foreach (f; mFaceList) {
            result = dg(f);
            if (result) break;
        }
        return result;
    }

    uint[] getIndexList() {
        return mFaceList.map!(a => a.IndexList).array.join;
    }

    void setVertexList(VertexList vList) {
        mVertexList = vList;
        mFaceList.each!(face => face.associateVertices(vList));
    }

    VertexList getVertexList() @nogc {
        return mVertexList;
    }

    void expandVertex() {
        assert(mVertexList);
        auto newVertexList = new VertexList(
                getIndexList().map!(index => mVertexList[index].dup).array
                );
        int newIndex = 0;
        Face[] newFaceList;
        foreach (face; mFaceList) {
            uint[] newIndexList;
            foreach (index; 0..face.IndexList.length) {
                newIndexList ~= newIndex++;
            }
            newFaceList ~= new Face(newIndexList, Face.Type.Triangles);
        }
        mFaceList = newFaceList;
        setVertexList(newVertexList);
    }

    void generateFlatNormal() {
        assert(getIndexList.length == mVertexList.length);
        foreach (face; mFaceList) {
            auto vertices = face.getChildren();
            auto normal = face.computeNormal();
            foreach (v; vertices) {
                v.Normal = normal;
            }
        }
    }

    void generateSmoothNormal() {
        foreach (v; mVertexList) {
            v.Normal = vec3(0);
        }
        foreach (v; mVertexList) {
            foreach (face; v.mParents) {
                v.Normal = v.Normal + face.computeNormal();
            }
        }
        foreach (v; mVertexList) {
            v.Normal = normalize(v.Normal);
        }
    }

    void generateTexcoord() {
        assert(getIndexList.length == mVertexList.length);
        foreach (face; mFaceList) {
            auto children = face.getChildren;
            assert(children.length >= 2);
            auto center = face.computeCenter();
            auto z = face.computeNormal();
            auto x = normalize(children[0].Position - center);
            auto y = cross(z, x).normalize;
            float minS = float.infinity;
            float minT = float.infinity;
            float maxS = -float.infinity;
            float maxT = -float.infinity;
            foreach (v; children) {
                float s = dot(v.Position, x);
                float t = dot(v.Position, y);
                v.Texcoord = vec2(s,t);
                minS = min(minS, s);
                minT = min(minT, t);
                maxS = max(maxS, s);
                maxT = max(maxT, t);
            }
            vec2 origin = vec2(minS, minT);
            vec2 scale = 1 / vec2(maxS - minS, maxT - minT);
            alias conv = tc => (tc - origin) * scale;
            foreach (v; children) {
                v.Texcoord = conv(v.Texcoord);
            }
        }
    }
}
