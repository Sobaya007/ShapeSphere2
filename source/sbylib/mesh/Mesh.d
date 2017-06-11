module sbylib.mesh.Mesh;

import sbylib.mesh.Object3D;
import sbylib.geometry.Geometry;
import sbylib.material.Material;
import sbylib.camera.Camera;

class Mesh {
    Object3D obj;
    Geometry geom;
    Material mat;

    this() {
        this.obj = new Object3D();
    }

    void render() {
        this.geom.render(this.mat);
    }
}
