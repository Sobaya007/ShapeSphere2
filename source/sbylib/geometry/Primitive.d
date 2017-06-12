//module sbylib.geometry.Geometry;

import std.algorithm, std.conv, std.array;

import sbylib.math;
import sbylib.geometry;
import sbylib.utils;
import sbylib.wrapper.gl;
import sbylib.core;

/*
   図形を表すクラスです。
   基本はposとorientation、そしてdrawを提供する抽象クラスですが、
   演算子オーバーロードに加え、ワールド変換行列を自動的に生成します。
 */

//class Geometry {
//
//    private {
//        vec3 mPosition = vec3(0);
//        quat mOrientation = quat(0,0,0,1);
//        mat4 mMatWorld = mat4.identity;
//        FaceList mFaceList;
//        bool mMatWorldUpdateFlag = false;
//        bool mCustomAssigned = false;
//        uint mVertexNum;
//    }
//
//    protected CustomObject mCustom;
//
//    this() {
//
//    }
//
//    this(CustomObject custom) {
//        this.mCustom = custom;
//    }
//
//    this(vec3[] vertex, uint[][] faceIndexList, ShaderProgram shader) in {
//        assert(faceIndexList.all!(a => a.length >= 3), "some face have less than 3 indices.");
//    } body {
//        VertexList vList = new VertexList(vertex);
//        FaceList fList = new FaceList(faceIndexList, Face.Type.TriangleFan);
//        fList.setVertexList(vList);
//        this(fList, shader);
//    }
//
//    this(FaceList faceList, ShaderProgram shader) {
//        if (faceList is null) return; //for Grouped Geometry
//        this.mCustom = new CustomObject(shader, Prim.Triangle);
//        this.mCustomAssigned = true;
//        this.mVertexNum = to!uint(faceList.getVertexList.length);
//        this.mFaceList = faceList;
//        vec3[] positionList;
//        vec3[] normalList;
//        vec2[] texcoordList;
//        with (faceList.getVertexList) {
//            positionList.length = normalList.length = texcoordList.length = length;
//            getPositionList(positionList);
//            if (hasNormal)
//                getNormalList(normalList);
//            if (hasTexcoord)
//                getTexcoordList(texcoordList);
//        }
//        with (mCustom) {
//            beginMesh;
//            addAttribute!(3, "mVertex")(positionList, GpuSendFrequency.Static);
//            if (faceList.getVertexList.hasNormal)
//                addAttribute!(3, "mNormal")(normalList, GpuSendFrequency.Static);
//            if (faceList.getVertexList.hasTexcoord)
//                addAttribute!(2, "mTexcoord")(texcoordList, GpuSendFrequency.Static);
//            setIndex(faceList.getIndexList, GpuSendFrequency.Static);
//            addDynamicUniformMatrix!(4, "mWorld")({return getWorldMatrix.array;});
//            //addDynamicUniformMatrix!(4, "mViewProj")({return SbyWorld.currentCamera.getViewProjectionMatrix.array;});
//            endMesh;
//        }
//    }
//
//    mat4 getWorldMatrix() @nogc {
//        if (mMatWorldUpdateFlag) {
//            mMatWorld = mat4.translate(Position) * Orientation.toMatrix4;
//            mMatWorldUpdateFlag = false;
//        }
//        return mMatWorld;
//    }
//
//    void opOpAssign(string op)(vec3 v) {
//        static if (op == "+") {
//            Position = Position + v;
//        } else static if (op == "-") {
//            Position = Position - v;
//        } else {
//            static assert(false);
//        }
//        mMatUpdateFlag = true;
//    }
//
//    void opOpAssign(string op)(mat4 m) {
//        static if (op == "*") {
//            mMatWorld *= m;
//        }
//    }
//
//    CustomObject getCustom() {
//        return mCustom;
//    }
//
//    FaceList getFaceList() @nogc {
//        return mFaceList;
//    }
//
//    //頂点のローカル座標を変更します
//    void updatePositionList(vec3[] posList) {
//        mFaceList.getVertexList.setPositionList(posList);
//        mCustom.update("mVertex", posList.map!(a => a.array).array.reduce!((a,b) => a ~ b));
//    }
//
//    //頂点のグローバル座標が指定されたものになるようにローカル座標を変更します
//    void updatePositionListAsTransformed(vec3[] posList) {
//        auto m = mat4.invert(getWorldMatrix);
//        foreach (ref v; posList) {
//            v = (m * vec4(v,1)).xyz;
//        }
//        updatePositionList(posList);
//    }
//
//    @property @nogc {
//        const(vec3) Position(vec3 p) {
//            mMatWorldUpdateFlag = true;
//            return mPosition = p;
//        }
//
//        const(vec3) Position() {
//            return mPosition;
//        }
//
//        const(quat) Orientation(quat q) {
//            mMatWorldUpdateFlag = true;
//            return mOrientation = q;
//        }
//
//        const(quat) Orientation() {
//            return mOrientation;
//        }
//    }
//
//    bool step() in {
//        assert(mCustomAssigned, "Please override draw() when using default constructor.");
//    } body {
//        mCustom.draw;
//        return true;
//    }
//
//    alias draw = step;
//
//    void cacheTransform() {
//        auto m = getWorldMatrix;
//        foreach (v; mFaceList.getVertexList) {
//            auto v4 = m * vec4(v.Position,1);
//            auto n4 = m * vec4(v.Normal,0);
//            v.TransformedPosition = v4.xyz / v4.w;
//            v.TransformedNormal = n4.xyz;
//        }
//        foreach (f; mFaceList) {
//            auto n4 = m * vec4(f.computeNormal, 0);
//            f.TransformedNormal = n4.xyz;
//        }
//    }
//}
