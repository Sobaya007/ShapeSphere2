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
    auto screen = window.getScreen();
    auto world = new World();
    auto viewport = new AspectFixViewport(window);
    auto renderer = new Renderer(world, screen, viewport);

    OrthoCamera camera = new OrthoCamera(1, 1, -1, 1);
    camera.pos = vec3(+0.5, +0.5, 0);
    world.setCamera(camera);

    auto dataset = new DataSet(TimeLogger.TIME_LOG_PATH);

    foreach (key, value; dataset.lineMesh) {
        world.add(value);
    }
    foreach (key, value; dataset.labels) {
        world.add(value);
    }

    auto render = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render();
    };

    auto mouse = new ViewportMouse(viewport);
    auto mouseMove = delegate (Process proc) {
        if (mouse.isPressed(MouseButton.Button1)) {
            camera.width  -= mouse.dif.x * 0.001;
            camera.height -= mouse.dif.y * 0.001;
        } else if (mouse.isPressed((MouseButton.Button2))) {
            camera.pos.x += mouse.dif.x * 0.001;
            camera.pos.y += mouse.dif.y * 0.001;
        }
    };
    core.addProcess(render, "render");
    core.addProcess(mouseMove, "mouse move");

    core.start();
}
