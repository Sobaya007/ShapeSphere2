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

    auto colcap1 = new CollisionCapsule(0.2, 1);
    auto col1 = new CollisionMesh(colcap1);
    auto material = new ConditionalMaterial!(NormalMaterial, TextureMaterial)();
    auto capsule1 = new Mesh(colcap1.createGeometry(), material, colcap1.obj);
    world3d.addMesh(capsule1);
    material.texture = Utils.generateTexture(ImageLoader.load(RESOURCE_ROOT ~ "uv.png"));

    auto colcap2 = new CollisionCapsule(0.2, 1);
    auto col2 = new CollisionMesh(colcap2);
    auto material2 = new ConditionalMaterial!(NormalMaterial, TextureMaterial)();
    auto capsule2 = new Mesh(colcap2.createGeometry(), material2, colcap2.obj);
    material2.texture = Utils.generateTexture(ImageLoader.load(RESOURCE_ROOT ~ "uv.png"));
    world3d.addMesh(capsule2);

    core.addProcess((proc) {
        world3d.render(core.getWindow().getRenderTarget());
        clear(ClearMode.Depth);
        world2d.render(core.getWindow().getRenderTarget());
    });

    BasicControl control = new BasicControl(capsule1.obj);

    core.addProcess((proc) {
        control.update(core.getWindow(), world2d.camera);
        material.condition = col1.collide(col2).collided;
        material2.condition = col2.collide(col1).collided;
    });

    core.start();
}
