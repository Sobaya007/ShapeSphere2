module examples.FramebufferExample;

import sbylib;

void framebufferExample() {
    auto core = Core();
    auto world = new World;
    auto internalWorld = new World;
    auto window = core.getWindow();
    auto screen = window.getScreen();
    auto renderer = new Renderer();
    auto viewport = new AutomaticViewport(window);


    Camera camera = new PerspectiveCamera(
            window.getWidth() / window.getHeight(), /* Aspect Ratio   */
            60.deg, /* FOV (in angle) */
            0.1, /* Near Clip      */
            100, /* Far Clip       */
    );
    camera.pos = vec3(3, 2, 9);
    camera.lookAt(vec3(0,2,0));
    world.setCamera(camera);


    auto planeMat = new CheckerMaterial!(LambertMaterial, LambertMaterial);
    planeMat.ambient1 = vec3(1);
    planeMat.ambient2 = vec3(0.5);
    planeMat.size = 0.015; /* Checker Size (in UV) */
    auto planeEntity = new Entity(Plane.create(100,100), planeMat);
    world.add(planeEntity);


    auto boxEntity = new Entity(Box.create(10,10,10), new TextureMaterial);
    boxEntity.obj.pos = vec3(0,2,0);
    world.add(boxEntity);

    auto boxEntity2 = new Entity(Box.create(10,10,10), new NormalMaterial);


    auto renderToScreen = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    };
    core.addProcess(renderToScreen, "render");


    auto control = new CameraControl(core.getKey(), core.getMouse(), camera);
    core.addProcess(&control.update, "update");


    core.addProcess({
        if (core.getKey().justPressed(KeyButton.Escape)) {
            core.end();
        }
    }, "a");


    core.start();
}
