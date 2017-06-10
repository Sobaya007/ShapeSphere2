module sbylib.camera.OrthoCamera;

import sbylib;

/*
   平行投影モデルを採用したカメラです。
   遠近感がありませんので、2D描画などに用います。
 */

final class OrthoCamera : Camera {
public:

    immutable {
        float width;
        float height;
        float nearZ;
        float farZ;
    }

    const {
        Object3D obj;
    }

    alias obj this;

    this(float width, float height, float nearZ, float farZ) {
        this.width = width;
        this.height = height;
        this.nearZ = nearZ;
        this.farZ = farZ;
        this.obj = new Object3D();
    }

    override mat4 generateProjectionMatrix() {
        return mat4.ortho(width, height, nearZ, farZ);
    }
}
