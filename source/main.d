import std.stdio;
import std.math;

import sbylib;

void main() {
    auto core = new Core();

    auto world3d = new World;
    world3d.camera = new PerspectiveCamera(1, 120, 0.1, 100);
    world3d.camera.getObj().pos.z += 3;

    auto world2d = new World;
    world2d.camera = new OrthoCamera(2,2,-1,1);

    auto sphere = new Mesh(Poll.create(0.5, 1), new NormalMaterial());
    world3d.addMesh(sphere);

    Font font = FontLoader.load(RESOURCE_ROOT  ~ "consola.ttf", 128);

    auto label = new Label(font, 0.1);
    label.text = "abcdefghijklmnopqrstuvwxyz";
    world2d.addMesh(label.meshes);

    core.addProcess((proc) {
        world3d.render(core.getWindow().getRenderTarget());
        clear(ClearMode.Depth);
        world2d.render(core.getWindow().getRenderTarget());
    });

    BasicControl control = new BasicControl(sphere.obj);

    core.addProcess((proc) {
        control.update(core.getWindow(), world2d.camera);
    });

    core.start();
}
