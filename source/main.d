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

    auto material = new TextureMaterial;
    auto sphere = new Mesh(Capsule.create(0.2, 1), material);
    world3d.addMesh(sphere);

   material.texture = Utils.generateTexture(ImageLoader.load(RESOURCE_ROOT ~ "uv.png"));

    Font font = FontLoader.load(RESOURCE_ROOT  ~ "consola.ttf", 128);

    auto label = new Label(font, 0.1);
    label.text = "abcdefghijklmnopqrstuvwxyz";
    //world2d.addMesh(label.meshes);

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
