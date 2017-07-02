module plot.Main;

import plot.Data;
import plot.DataSet;
import plot.circle;
import sbylib;

import std.stdio;
import std.random;
import std.math;

void plotMain() {
    auto core = new Core;
    auto world = new World();

    auto camera = new OrthoCamera(1, 1, -1, 1);
    camera.getObj().pos = vec3(+0.5, +0.5, 0);
    world.camera = camera;

    auto dataset = new DataSet(TIME_LOG_PATH);

    foreach (key, value; dataset.lineMesh) {
        world.addMesh(value);
    }
    foreach (key, value; dataset.labels) {
        world.addMesh(value.meshes);
    }

    auto render = delegate (Process proc) {
        clear(ClearMode.Color, ClearMode.Depth);
        world.render(core.getWindow().getRenderTarget());
    };

    auto mouse = new Mouse;
    auto mouseMove = delegate (Process proc) {
        mouse.update(core.getWindow());
        if (mouse.isPressed(MouseButton.Button1)) {
            camera.width  -= mouse.getDif().x * 0.001;
            camera.height -= mouse.getDif().y * 0.001;
        } else if (mouse.isPressed((MouseButton.Button2))) {
            camera.getObj().pos.x += mouse.getDif().x * 0.001;
            camera.getObj().pos.y += mouse.getDif().y * 0.001;
        }
    };
    core.addProcess(render, "render");
    core.addProcess(mouseMove, "mouse move");

    core.start();
}
