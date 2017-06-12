module sbylib.camera.Camera;

import sbylib.math.Matrix;
import sbylib.mesh.Object3D;
import sbylib.wrapper.gl.Uniform;
import sbylib.utils.Watcher;

/*
   カメラを表す抽象クラスです。
   generateProjectionMatrix,getCameraRayを実装することで継承可能です。

NearZ : ニアクリップ
FarZ  : ファークリップ
pos   :  位置(setter)
getPos : 位置(getter)
vecX,Y,Z : 基底(setter)
getVecX,Y,Z : 基底(getter)
target : 注視点(setter)
getViewMatrix : ビュー行列
getProjectionMatrix : 射影変換行列
getViewProjectionMatrix : 射影変換行列　x　ビュー行列
getCameraRay : カメラのレイ
 */

interface Camera {
    inout(Object3D) getObj() inout;
    @property Watcher!umat4 projMatrix();
    alias getObj this;
}
//abstract class Camera : Primitive {
//
//protected:
//    bool viewUpdate = true;
//    mat4 viewMatrix;
//    protected bool projUpdate = true;
//    mat4 projMatrix;
//    bool[3] baseUpdate = true;
//    vec3[3] base;
//    bool viewProjUpdate;
//    mat4 viewProjMatrix;
//    float nearZ, farZ;
//
//public:
//
//    this() {
//        Position = vec3(0,0,-1);
//        vecX = vec3(-1,0,0);
//    }
//
//    mixin CreateSetterGetter!(nearZ, "projUpdate = true;", "");
//    mixin CreateSetterGetter!(farZ, "projUpdate = true;", "");
//
//    @property {
//        override vec3 Position(vec3 p) {
//            baseUpdate[0] = baseUpdate[2] = true;
//            viewUpdate = true;
//            viewProjUpdate = true;
//            return super.Position(p);
//        }
//
//        override vec3 Position() { //これがないとCEくらう。D言語はクソ。
//            return super.Position();
//        }
//
//        override quat Orientation(quat q) {
//            assert(false, "面倒なので実装してない");
//        }
//
//        vec3 getVecX() {
//            if (baseUpdate[0]) {
//                baseUpdate[0] = false;
//                base[0] = normalize(base[0]);
//            }
//            return base[0];
//        }
//
//        void vecX(vec3 v) {
//            base[0] = v;
//            baseUpdate[0] = true;
//            viewUpdate = true;
//            viewProjUpdate = true;
//        }
//        vec3 getVecY() {
//            if (baseUpdate[1]) {
//                baseUpdate[1] = false;
//                base[1] = normalize(base[1]);
//            }
//            return base[1];
//        }
//        void vecY(vec3 v) {
//            base[1] = v;
//            baseUpdate[1] = true;
//            viewUpdate = true;
//            viewProjUpdate = true;
//        }
//        vec3 getVecZ() {
//            if (baseUpdate[2]) {
//                baseUpdate[2] = false;
//                base[2] = normalize(base[2]);
//            }
//            return base[2];
//        }
//        void vecZ(vec3 v) {
//            base[2] = v;
//            baseUpdate[2] = true;
//            viewUpdate = true;
//            viewProjUpdate = true;
//        }
//
//        void target(vec3 t) {
//            vecZ(normalize(Position() - t));
//        }
//    }
//
//    mat4 getViewMatrix() {
//        if (viewUpdate) {
//            viewUpdate = false;
//            viewMatrix = mat4.lookAt(Position, getVecZ, getVecY);
//        }
//        return viewMatrix;
//    }
//
//    mat4 getProjectionMatrix() {
//        if (projUpdate) {
//            projUpdate = false;
//            projMatrix = generateProjectionMatrix();
//        }
//        return projMatrix;
//    }
//
//    mat4 getViewProjectionMatrix() {
//        if (viewProjUpdate) {
//            viewProjUpdate = false;
//            viewProjMatrix = getProjectionMatrix() * getViewMatrix();
//        }
//        return viewProjMatrix;
//    }
//
//    mat4 getBillboardMatrix() {
//        import std.math;
//        auto mat = mat4.lookAt(vec3(0,0,0), getVecZ, getVecY);
//        return mat4.invert(mat);
//    }
//
//    protected abstract mat4 generateProjectionMatrix();
//
//    abstract Ray getCameraRay(vec2 windowPos);
//
//}
