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
    auto renderer = new Renderer();
    auto viewport = new AutomaticViewport(window);

    OrthoCamera camera = new OrthoCamera(1, 1, -1, 1);
    camera.pos = vec3(+0.5, +0.5, 0);
    world.setCamera(camera);

    auto dataset = new DataSet(TimeLogger.TIME_LOG_PATH);

    foreach (key, value; dataset.lineMesh) {
        world.add(value);
    }
    foreach (key, value; dataset.labels) {
        world.add(value.entity);
    }

    auto render = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    };

    auto mouse = new ViewportMouse(viewport);
    auto mouseMove = delegate (Process proc) {
        if (mouse.isPressed(MouseButton.Button1)) {
            camera.width  -= mouse.getDif().x * 0.001;
            camera.height -= mouse.getDif().y * 0.001;
        } else if (mouse.isPressed((MouseButton.Button2))) {
            camera.pos.x += mouse.getDif().x * 0.001;
            camera.pos.y += mouse.getDif().y * 0.001;
        }
    };
    core.addProcess(render, "render");
    core.addProcess(mouseMove, "mouse move");

    core.start();
}
