module examples.text2d;

import sbylib;

void mainText2d() {
    auto core = Core();
    auto screen = core.getWindow().getRenderTarget();
    auto world = new World;
    auto camera = new OrthoCamera(2,2,-1,1);
    auto font = FontLoader.load(RESOURCE_ROOT ~ "consola.ttf", 64);
    auto label = new Label(font, 0.1);

    auto render = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        world.render(screen);
    };

    world.camera = camera;
    world.addMesh(label);
    core.addProcess!(render);

    core.start();
}
