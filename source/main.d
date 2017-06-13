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
        time += 0.05;
        auto c = cos(time);
        auto s = sin(time);
    });
    world.meshes ~= mesh;
    mesh.obj.pos = vec3(1,0,0);
    world.camera = new PerspectiveCamera(1, 120, 0.1, 100);
    world.camera.pos = vec3(0,0,2);
    world.camera.lookAt(vec3(0));
    UniformResolver.resolve(world);
    core.world = world;

    auto vs = [vec4(+0.5,+0.5,+0.5, 1),
    vec4(+0.5,-0.5,+0.5, 1),
    vec4(-0.5,-0.5,+0.5, 1),
    vec4(-0.5,+0.5,+0.5, 1)];
    auto v = vs[0];

    writeln(mesh.obj.worldMatrix);
    writeln(world.viewMatrix);
    writeln(world.projMatrix);
    writeln(mesh.obj.worldMatrix * v);
    writeln(world.viewMatrix * (mesh.obj.worldMatrix * v));
    auto p = world.projMatrix * (world.viewMatrix * (mesh.obj.worldMatrix * v));
    writeln(p);
    writeln(p.xyz / p.w);

    core.start();
}
