import std.stdio;
import std.math;

import sbylib;
import player.ElasticSphere;

void main() {
    auto core = new Core();

    auto world3d = new World;
    world3d.camera = new PerspectiveCamera(1, 120, 0.1, 100);
    world3d.camera.getObj().pos = vec3(3, 4, 5);
    world3d.camera.getObj().lookAt(vec3(0));

    auto world2d = new World;
    world2d.camera = new OrthoCamera(2,2,-1,1);

    core.addProcess((proc) {
        world3d.render(core.getWindow().getRenderTarget());
        clear(ClearMode.Depth);
        world2d.render(core.getWindow().getRenderTarget());
    });

    ElasticSphere esphere = new ElasticSphere();
    world3d.addMesh(esphere.mesh);
    core.addProcess((proc) {
        esphere.move();
    });

    core.start();
}
