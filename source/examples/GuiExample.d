module examples.GuiExample;

import sbylib;

void guiExample() {
    auto core = Core();
    auto window = core.getWindow();
    auto world = new World;
    auto viewport = new AspectFixViewport(window);


    auto screen = window.getScreen();
    screen.setClearColor(vec4(0.2));

    auto renderer = new Renderer(world, screen, viewport);


    auto camera = new OrthoCamera(2,2,-1,1);
    world.setCamera(camera);


    auto timeline = new Timeline();
    timeline.add(0);
    world.add(timeline.entity());
    timeline.add(0);


    auto control = new GuiControl(window, camera, viewport, world, core.getKey());
    control.add(timeline);
    core.addProcess(&control.update, "control");


    auto fpsCounter = new FpsCounter!100;


    core.getKey().justPressed(KeyButton.Escape).add(() => core.end);


    core.addProcess({
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render();
        fpsCounter.update();
        timeline.add(fpsCounter.getFPS());
    }, "render");

    core.start();
}
