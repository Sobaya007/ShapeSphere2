import std.stdio;
import std.math;

import sbylib;

import derelict.opengl;

void main() {
    auto core = new Core();
    auto world = new World;
    auto mesh = new Mesh(Box.get(), new LambertMaterial());
    auto time = 0.0f;
    core.addProcess((proc){
        time += 0.006;
        auto c = cos(time);
        auto s = sin(time);
        world.camera.pos = vec3(5*s,2,5*c);
        world.camera.lookAt(vec3(0));
    });
    world.meshes ~= mesh;
    auto image = ImageLoader.load("./Resource/d.png");
    //auto utex = new utexture("tex");
    //utex.value = Utils.generateTexture(image);
    //mesh.mat.addUniform(utex);
    world.camera = new PerspectiveCamera(1, 120, 0.1, 100);
    UniformResolver.resolve(world);
    core.world = world;
    core.start();
}
