module sbylib.mesh.Mesh;

import sbylib.mesh.Object3D;
import sbylib.geometry.Geometry;
import sbylib.material.Material;
import sbylib.camera.Camera;
import sbylib.wrapper.gl.VertexArray;
import std.traits;

class Mesh {
    Object3D obj;
    Geometry geom;
    Material mat;
    private VertexArray vao;

    this(Geometry geom, Material mat, Object3D obj = new Object3D) {
        this.obj = obj;
        this.geom = geom;
        this.mat = mat;
        this.vao = new VertexArray;
        this.vao.setup(mat.shader, geom.getBuffers(), geom.getIndexBuffer());
    }

    void render() in {
        assert(this.geom);
        assert(this.mat);
    } body{
        this.mat.set();
        this.geom.render(this.vao);
    }
}
