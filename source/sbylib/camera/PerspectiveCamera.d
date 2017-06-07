module sbylib.camera.PerspectiveCamera;

import std.math, std.string, std.stdio;

import sbylib.camera;
import sbylib.utils;
import sbylib.math;
import sbylib.geometry;
import sbylib.core;
import sbylib.mesh;

/*
   視錐台モデルを採用したカメラです。
   遠近感の出る一般的なカメラで、3D描画に用います。
 */

final class PerspectiveCamera : Camera {
public:
    immutable {
        float aspectWperH;
        float fovy;
        float nearZ;
        float farZ;
    }

    const {
        Object3D obj;
    }

    alias obj this;

    this(float aspect, float fovy, float nearZ, float farZ) {
        this.aspectWperH = aspect;
        this.fovy = fovy;
        this.nearZ = nearZ;
        this.farZ = farZ;
        this.obj = new Object3D();
    }

    override mat4 generateProjectionMatrix() {
        return mat4.perspective(aspectWperH, fovy, nearZ, farZ);
    }
}
