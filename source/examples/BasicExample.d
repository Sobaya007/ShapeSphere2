module examples.BasicExample;

import sbylib;

void basicExample() {
    auto core = Core();
    auto world = new World;
    auto window = core.getWindow();
    auto screen = window.getScreen();
    auto renderer = new Renderer();
    auto viewport = new AutomaticViewport(window);


    auto camera = new PerspectiveCamera(
            window.getWidth() / window.getHeight(), /* Aspect Ratio   */
            60.deg, /* FOV (in angle) */
            0.1, /* Near Clip      */
            100, /* Far Clip       */);
    camera.pos = vec3(3, 2, 9);
    camera.lookAt(vec3(0,2,0));
    world.setCamera(camera);

    auto planeEntity = makeEntity(
            Plane.create(100,100), /* width, height */
            new CheckerMaterial!(LambertMaterial, LambertMaterial)
    );
    planeEntity.ambient1 = vec3(1);
    planeEntity.mat.ambient2 = vec3(0.5);
    planeEntity.size = 0.015; /* Checker Size (in UV) */
    world.add(planeEntity);


    auto boxEntity = makeEntity(Box.create(10,10,10), new NormalMaterial);
    boxEntity.pos = vec3(0,2,0);
    world.add(boxEntity);

    auto renderToScreen = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    };

    core.addProcess(renderToScreen, "render");

    core.start();
}
