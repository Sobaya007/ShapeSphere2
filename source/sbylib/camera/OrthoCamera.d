module sbylib.camera.OrthoCamera;

import sbylib;

/*
   平行投影モデルを採用したカメラです。
   遠近感がありませんので、2D描画などに用います。
 */

final class OrthoCamera : Camera {
private:
    float width, height;
public:

    this(float width, float height, float nearZ, float farZ) {
        this.width = width;
        this.height = height;
        this.nearZ = nearZ;
        this.farZ = farZ;
    }

    mixin CreateSetterGetter!(width, "projUpdate = true;", "");
    mixin CreateSetterGetter!(height, "projUpdate = true;", "");

    override mat4 generateProjectionMatrix() {
        return mat4.ortho(width, height, nearZ, farZ);
    }

    override Ray getCameraRay(vec2 windowPos) {
        return new Ray(Position, getVecZ);
    }

}
