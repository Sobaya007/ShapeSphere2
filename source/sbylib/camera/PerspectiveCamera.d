module sbylib.camera.PerspectiveCamera;

import std.math, std.string, std.stdio;

import sbylib.camera;
import sbylib.utils;
import sbylib.math;
import sbylib.primitive;
import sbylib.core;

/*
   視錐台モデルを採用したカメラです。
   遠近感の出る一般的なカメラで、3D描画に用います。
 */

final class PerspectiveCamera : Camera {
    float aspectWperH;
    float fovy;
public:

    this(float aspect, float fovy, float nearZ, float farZ) {
        this.aspectWperH = aspect;
        this.fovy = fovy;
        this.nearZ = nearZ;
        this.farZ = farZ;
    }

    mixin CreateSetterGetter!(aspectWperH, "projUpdate = true;", "");
    mixin CreateSetterGetter!(fovy, "projUpdate = true;", "");

    override mat4 generateProjectionMatrix() {
        return mat4.perspective(aspectWperH, fovy, nearZ, farZ);
    }

    override Ray getCameraRay(vec2 windowPos) {

        auto tan = tan(fovy/2);
        auto vector = vec3(windowPos / vec2(SbyWorld.currentWindow.viewportWidth, SbyWorld.currentWindow.viewportHeight) - 0.5, 1);
        vector.y *= -1;
        vector.x *= 2 * aspectWperH * tan;
        vector.y *= 2 * tan;
        vector = (mat4.invert(getViewMatrix) * vec4(vector, 0) ).xyz;
        return new Ray(Position, vector);
    }

}
