import std.stdio;
import std.math;

import sbylib;

import derelict.opengl;

void main() {
    auto core = new Core();
    auto world = new World;
    auto mesh = new Mesh(Sphere.create(0.5, 2), new LambertMaterial());
    auto time = 0.0f;
    core.addProcess((proc){
        time += 0.006;
        auto c = cos(time);
        auto s = sin(time);
        world.camera.pos = vec3(5*s,2,5*c);
        //world.camera.pos = vec3(0,2,-5);
        world.camera.lookAt(vec3(0));
    });
    world.camera = new PerspectiveCamera(1, 120, 0.1, 100);
    mesh.mat.config.backMode = PolygonMode.Fill;
    world.addMesh(mesh);
    Viewport viewport = new Viewport(0,0, core.getWindow().getWidth(), core.getWindow().getHeight());
    core.addProcess((proc) {
        world.render(viewport);
    });

    BasicControl control = new BasicControl(mesh.obj);

    core.addProcess((proc) {
        control.update(core.getWindow(), world.camera);
    });

    core.start();
}
