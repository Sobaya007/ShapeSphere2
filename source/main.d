import std.stdio;

import sbylib;

import derelict.opengl;

void main() {
    auto core = new SbyCore();
    auto world = new World;
    auto mesh = new Mesh;
    mesh.mat = new LambertMaterial(mesh.obj.worldMatrix, world.viewMatrix, world.projMatrix);
    world.meshes ~= mesh;
    world.camera = new PerspectiveCamera(1, 120, 0.1, 100);

    core.setFPS(60);
    core.start();
}
