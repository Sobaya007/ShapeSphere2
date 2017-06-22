import std.stdio;
import std.math;

import sbylib;

void main() {
    auto core = new Core();
    auto world = new World;
    auto time = 0.0f;
    world.camera = new PerspectiveCamera(1, 120, 0.1, 100);

    core.addProcess((proc){
        time += 0.006;
        time = 0;
        auto c = cos(time);
        auto s = sin(time);
        world.camera.getObj().pos = vec3(5*s,2,5*c);
        //world.camera.pos = vec3(0,2,-5);
        world.camera.getObj().lookAt(vec3(0));
    });

    Font font = FontLoader.load(RESOURCE_ROOT  ~ "consola.ttf", 128);
    auto label = new Label(font, 0.1);
    label.text = "abcdefghijklmnopqrstuvwxyz";
    foreach (mesh; label.meshes) {
        world.addMesh(mesh);
    }

    Viewport viewport = new Viewport(0,0, core.getWindow().getWidth(), core.getWindow().getHeight());
    core.addProcess((proc) {
        world.render(viewport);
    });

    BasicControl control = new BasicControl(label.obj);

    core.addProcess((proc) {
        control.update(core.getWindow(), world.camera);
    });

    core.start();
}
