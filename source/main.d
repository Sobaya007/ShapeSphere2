import std.stdio;
import std.math;

import sbylib;
import player.ElasticSphere;

void main() {
    auto core = new Core();

    auto world3d = new World;
    world3d.camera = new PerspectiveCamera(1, 120, 0.1, 100);
    world3d.camera.getObj().pos = vec3(3, 5, 9);
    world3d.camera.getObj().lookAt(vec3(0));

    auto world2d = new World;
    world2d.camera = new OrthoCamera(2,2,-1,1);

    core.addProcess((proc) {
        world3d.render(core.getWindow().getRenderTarget());
        clear(ClearMode.Depth);
        world2d.render(core.getWindow().getRenderTarget());
    });

    auto texture = Utils.generateTexture(ImageLoader.load(RESOURCE_ROOT ~ "uv.png"));
    ElasticSphere esphere = new ElasticSphere();
    foreach (floor; esphere.floors) {
        auto mat = new TextureMaterial();
        mat.texture = texture;
        world3d.addMesh(new Mesh(floor.createGeometry(), mat, floor.obj));
    }
    world3d.addMesh(esphere.mesh);
    core.addProcess((proc) {
        esphere.move();
    });

    core.start();
}
