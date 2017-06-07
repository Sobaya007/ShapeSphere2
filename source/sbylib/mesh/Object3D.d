module sbylib.mesh.Object3D;

import sbylib.math, sbylib.geometry;

class Object3D {
    vec3 position;
    quat rot;

    mat4 generateViewMatrix() {
        return mat4.lookAt(position, rot.baseZ, rot.baseY);
    }
}
