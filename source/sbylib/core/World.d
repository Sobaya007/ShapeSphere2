module sbylib.core.World;

import sbylib.mesh.Mesh;
import sbylib.camera.Camera;
import sbylib.utils.Watcher;
import sbylib.wrapper.gl.Uniform;

class World {
    Mesh[] meshes;
    Watch!Camera camera;
    Watcher!umat4 viewMatrix;
    Watcher!umat4 projMatrix;

    this() {
        this.camera = new Watch!Camera;
        this.viewMatrix = new Watcher!umat4((ref umat4 mat) {
            mat.value = this.camera.viewMatrix;
            this.viewMatrix.addWatch(this.camera.viewMatrix);
        }, new umat4("viewMatrix"));
        this.viewMatrix.addWatch(this.camera);
        this.projMatrix = new Watcher!umat4((ref umat4 mat) {
            mat.value = this.camera.projMatrix;
            this.projMatrix.addWatch(this.camera.projMatrix);
        }, new umat4("projMatrix"));
        this.projMatrix.addWatch(this.camera);
    }

    void render() {
        assert(this.camera.get());
        foreach(Mesh m; meshes) {
            m.render();
        }
    }
}
