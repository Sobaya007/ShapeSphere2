import std.stdio;
import std.math;

import sbylib;
import derelict.opengl;

void main() {
    auto core = new Core();
    auto world = new World;
    auto time = 0.0f;
    world.camera = new PerspectiveCamera(1, 120, 0.1, 100);

    core.addProcess((proc){
        time += 0.006;
        auto c = cos(time);
        auto s = sin(time);
        world.camera.pos = vec3(5*s,2,5*c);
        //world.camera.pos = vec3(0,2,-5);
        world.camera.lookAt(vec3(0));
    });

    auto mat = new LambertMaterial();
    mat.ambient = vec3(.1);
    auto mesh = new Mesh(Box.create(), mat);
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
