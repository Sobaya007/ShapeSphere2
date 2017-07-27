module plot.Main;

import plot.Data;
import plot.DataSet;
import plot.circle;
import sbylib;

import std.stdio;
import std.random;
import std.math;
import std.algorithm;
import std.array;

void plotMain() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getRenderTarget();
    auto world = new World();

    auto camera = new OrthoCamera(1, 1, -1, 1);
    camera.getObj().pos = vec3(+0.5, +0.5, 0);
    world.camera = camera;

    auto dataset = new DataSet(TIME_LOG_PATH);

    foreach (key, value; dataset.lineMesh) {
        world.add(value);
    }
    foreach (key, value; dataset.labels) {
        world.add(value.entity);
    }

    auto render = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        world.render(screen);
    };

    auto mouse = new Mouse(window);
    auto mouseMove = delegate (Process proc) {
        mouse.update();
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
