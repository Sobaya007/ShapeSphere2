module examples.gui;

import sbylib;

void mainGUI() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getRenderTarget();
    auto world = new Bahamut;
    auto leviathan = new Leviathan();
    auto camera = new OrthoCamera(2,2,-1,1);
    auto font = FontLoader.load(RESOURCE_ROOT ~ "HGRPP1.TTC", 256);
    auto control = new GuiControl(window, camera, world);
    auto timeline = new Timeline(font);
    screen.clearColor = vec4(0.2);
    auto fpsCounter = new FpsCounter!100;

    auto render = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        world.render(screen);
        fpsCounter.update();
        timeline.add(fpsCounter.getFPS());
    };
    timeline.add(0);
    world.camera = camera;
    world.add(timeline.getEntity());
    timeline.add(0);
    control.add(timeline);

    core.addProcess(render, "render");
    core.addProcess(&control.update, "control");

    core.start();
}
