module sbylib.mesh.Object3D;

import sbylib.math.Matrix;
import sbylib.math.Vector;
import sbylib.math.Quaternion;
import sbylib.utils.Watcher;
import sbylib.wrapper.gl.Uniform;

class Object3D {
    Watch!vec3 pos;
    Watch!quat rot;
    Watcher!umat4 worldMatrix;
    Watcher!umat4 viewMatrix;

    this() {
        this.pos = new Watch!vec3();
        this.pos = vec3(0);

        this.rot = new Watch!quat();
        this.rot = quat(0,0,0,1);

        this.worldMatrix = new Watcher!umat4((ref umat4 mat) {
            mat.value = generateWorldMatrix();
        }, new umat4("worldMatrix"));
        this.worldMatrix.addWatch(this.pos);
        this.worldMatrix.addWatch(this.rot);

        this.viewMatrix = new Watcher!umat4((ref umat4 mat) {
            mat.value = generateViewMatrix();
        }, new umat4("viewMatrix"));
        this.viewMatrix.addWatch(this.pos);
        this.viewMatrix.addWatch(this.rot);
    }

    private mat4 generateViewMatrix() {
        return mat4.lookAt(pos, rot.baseZ, rot.baseY);
    }

    private mat4 generateWorldMatrix() {
        return mat4(1-2*(rot.y*rot.y+rot.z*rot.z), 2*(rot.x*rot.y-rot.z*rot.w), 2*(rot.x*rot.z+rot.w*rot.y), pos.x,
                2*(rot.x*rot.y+rot.w*rot.z), 1-2*(rot.x*rot.x+rot.z*rot.z), 2*(rot.y*rot.z-rot.w*rot.x), pos.y,
                2*(rot.x*rot.z-rot.w*rot.y), 2*(rot.y*rot.z+rot.w*rot.x), 1-2*(rot.x*rot.x+rot.y*rot.y), pos.z,
                0, 0, 0, 1);
    }
}
