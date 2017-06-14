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
    auto uniform = new UniformBuffer("Po");
    struct Po {
        vec3 color;
    }
    Po po;
    po.color = vec3(1,0,0);
    uniform.sendData!Po(po);
    mesh.mat.addUniform(() => uniform);
    world.camera = new PerspectiveCamera(1, 120, 0.1, 100);
    UniformResolver.resolve(world);
    core.world = world;
    core.start();
}
