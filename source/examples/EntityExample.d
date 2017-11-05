module examples.EntityExample;

import sbylib;

void entityExample() {
    auto core = Core();

    auto world = new World;

    auto window = core.getWindow();

    auto screen = window.getScreen();

    auto renderer = new Renderer();

    auto viewport = new AutomaticViewport(window);

    auto camera = new OrthoCamera(2,2,-1,1);

    auto renderToScreen = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    };

    auto image = ImageEntity(ImagePath("uv.png"), 0.5, 0.5);
    auto text = TextEntity("aiueo", 0.5);

    text.pos = vec3(0,-0.2,0);

    world.setCamera(camera);
    world.add(image);
    world.add(text);
    core.addProcess(renderToScreen, "render");

    core.start();
}
