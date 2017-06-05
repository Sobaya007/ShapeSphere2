module sbylib.primitive.Capsule;

import std.math;

import sbylib.primitive;
import sbylib.math;
import sbylib.shadertemplates;

class Capsule : Primitive {

    private {
        enum N = 10; //theta
        enum M = 5; //phi
        float mSegmentLength;
        float mRadius;
        vec3[] mVertices;
        vec3 mStart;
        vec3 mEnd;
        FaceList mFaceList;

        static {
            uint[][] sIndices;
        }
    }

    //デフォルトではz軸方向のカプセル
    this(float segmentLength, float radius) {
        this.mSegmentLength = segmentLength;
        this.mRadius = radius;
        this.mStart = vec3(0,0,-segmentLength/2);
        this.mEnd   = vec3(0,0,+segmentLength/2);
        this.mVertices = new vec3[M*N*2+2];
        Capsule.getVertices(mStart, mEnd, radius, this.mVertices);
        auto vList = new VertexList(mVertices);
        this.mFaceList = new FaceList(Capsule.getIndices, Face.Type.TriangleFan);
        mFaceList.setVertexList(vList);
        mFaceList.generateSmoothNormal();
        super(mFaceList, ShaderStore.getShader("NormalGenerate"));
    }

    this(vec3 start, vec3 end, float radius) {
        this(length(end-start), radius);
        Start = start;
        End = end;
    }

    @property {
        float Radius(float r) {
            mRadius = r;
            Capsule.getVertices(
                    vec3(0,0,-mSegmentLength), vec3(0,0,mSegmentLength), Radius, this.mVertices);
            mFaceList.getVertexList.setPositionList(mVertices);
            return r;
        }

        vec3 Start(vec3 s) {
            assert(abs(s.x) !is float.nan);
            assert(abs(s.y) !is float.nan);
            assert(abs(s.z) !is float.nan);
            mStart = s;
            updatePositionOrientationLength();
            return s;
        }

        vec3 End(vec3 e) {
            mEnd = e;
            updatePositionOrientationLength();
            return e;
        }

        override {
            vec3 Position(vec3 p) {
                auto result = super.Position(p);
                auto pastCenter = (Start + End) / 2;
                auto moveVec = Position - pastCenter;
                recalculateStartEnd();
                assert(abs(moveVec.x) !is float.nan);
                assert(abs(moveVec.y) !is float.nan);
                assert(abs(moveVec.z) !is float.nan);
                return result;
            }

            quat Orientation(quat q) {
                auto result = super.Orientation(q);
                auto center = (Start + End) / 2;
                recalculateStartEnd();
                assert(abs(q.x) !is float.nan);
                assert(abs(q.y) !is float.nan);
                assert(abs(q.z) !is float.nan);
                assert(abs(q.w) !is float.nan);
                assert(abs(mStart.x) !is float.nan);
                assert(abs(mStart.y) !is float.nan);
                assert(abs(mStart.z) !is float.nan);
                return result;
            }

            vec3 Position() {
                return super.Position;
            }

            quat Orientation() {
                return super.Orientation;
            }
        }

        pure @nogc {
            float SegmentLength() {
                return mSegmentLength;
            }

            float Radius() {
                return mRadius;
            }

            vec3 Start() {
                return mStart;
            }

            vec3 End() {
                return mEnd;
            }
        }
    }

    private {
        void updatePositionOrientationLength() {
            auto s = Start;
            auto e = End;
            auto v = e - s;
            auto newPos = (s+e) / 2;
            auto newLength = v.length;
            v /= newLength;
            quat newOri;
            if (abs(v.x) !is float.nan) {
                newOri = quat.rotFromTo(vec3(0,0,1), v);
            } else {
                newOri = quat(0,0,0,1);
            }

            super.Position = newPos;
            super.Orientation = newOri;
            mSegmentLength = newLength;
            Capsule.getVertices(
                    vec3(0,0,-mSegmentLength/2), vec3(0,0,mSegmentLength/2), Radius, this.mVertices);
            updatePositionList(mVertices);
            recalculateStartEnd();
        }

        void recalculateStartEnd() @nogc {
            auto v = vec3(0,0,1);
            v = rotate(v, Orientation);
            mStart = Position - SegmentLength / 2 * v;
            mEnd   = Position + SegmentLength / 2 * v;
        }

    }

    static void getVertices(vec3 start, vec3 end, float r, ref vec3[] result) @nogc {

        vec3 getVertical(vec3 v) @nogc {
            if (v.x == 0 && v.y == 0) {
                if (v.z == 0) assert(false);
                return vec3(1,0,0);
            }
            return v.cross(vec3(0,0,1));
        }

        auto v = (end - start).normalize;
        if (v.x.abs is float.nan) v = vec3(0,0,1);
        auto t = getVertical(v).normalize;
        auto s = cross(t, v);
        int resCount = 0;

        //southern
        result[resCount++] = start - v * r;
        foreach_reverse (i; 0..M) {
            auto phi = i * PI / (2 * M);
            foreach (j; 0..N) {
                auto theta = j * 2 * PI / N;
                auto p = start - r * (v * sin(phi) + cos(phi) * (t * cos(theta) + s * sin(theta)));
                result[resCount++] = p;
            }
        }

        //northern
        result[resCount++] = end + v * r;
        foreach_reverse (i; 0..M) {
            auto phi = i * PI / (2 * M);
            foreach (j; 0..N) {
                auto theta = j * 2 * PI / N;
                auto p = end + r * (v * sin(phi) + cos(phi) * (t * cos(theta) + s * sin(theta)));
                result[resCount++] = p;
            }
        }
    }

    static uint[][] getIndices() {
        return sIndices;
    }

    static this() {
        //southernてっぺん
        foreach (i; 0..N) {
            sIndices ~= [0, i+1, (i+1) % N + 1];
        }

        //southernまわり
        foreach (i; 0..M-1) {
            foreach (j; 0..N) {
                sIndices ~= [
                1 + j + i * N, 
                1 + j+ (i+1) * N,
                1 + (j+1) % N + (i+1) * N,
                    1 + (j+1) % N + i * N,
                    ];
            }
        }

        //northernてっぺん
        foreach (i; 0..N) {
            sIndices ~= [M*N + 1,M*N + 1 + (i+1) % N + 1, M*N + 1 + i + 1];
        }

        //northernまわり
        foreach (i; 0..M-1) {
            foreach (j; 0..N) {
                sIndices ~= [
                M*N+2 + j + i * N,
                M*N+2 + (j+1) % N + i * N, 
                    M*N+2 + (j+1) % N + (i+1) * N,
                    M*N+2 + j+ (i+1) * N, 
                    ];
            }
        }

        //側面
        foreach (i; 0..N) {
            sIndices ~= [
            (M-1) * N + 1 + i,
            (2*M-2) * N + 2 + i + N / 2,
                (2*M-2) * N + 2 + (i+1) % N + N / 2,
                (M-1) * N + 1 + (i+1) % N,
                ];
        }
    }
}
