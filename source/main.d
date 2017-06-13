import std.stdio;

import sbylib;

import derelict.opengl;

void main() {
    auto core = new Core();
    auto world = new World;
    auto mesh = new Mesh;
    mesh.geom = Box.get();
    mesh.mat = new LambertMaterial(mesh.obj.worldMatrix, world.viewMatrix, world.projMatrix);
    world.meshes ~= mesh;
    world.camera = new PerspectiveCamera(1, 120, 0.1, 100);
    core.world = world;

    core.start();
}
