module examples.CameraControlExample;

import sbylib;

void cameraControlExample() {
    auto core = Core();

    auto world = new World;

    auto window = core.getWindow();

    auto screen = window.getScreen();

    auto renderer = new Renderer();

    auto viewport = new AutomaticViewport(window);

    Camera camera = new PerspectiveCamera(
            window.getWidth() / window.getHeight(), /* Aspect Ratio   */
            60.deg, /* FOV (in angle) */
            0.1, /* Near Clip      */
            100, /* Far Clip       */);
    camera.pos = vec3(3, 2, 9);
    camera.lookAt(vec3(0,2,0));

    auto control = new CameraControl(core.getKey(), core.getMouse(), camera);

    auto planeGeom = Plane.create(100, 100); /* width, height */

    auto planeMat = new CheckerMaterial!(LambertMaterial, LambertMaterial);
    planeMat.ambient1 = vec3(1);
    planeMat.ambient2 = vec3(0.5);
    planeMat.size = 0.015; /* Checker Size (in UV) */

    auto planeEntity = new Entity(planeGeom, planeMat);

    auto boxGeom = Box.create(10, 10, 10); /* width, height, depth */

    auto boxMat = new NormalMaterial;

    auto boxEntity = new Entity(boxGeom, boxMat);
    boxEntity.obj.pos = vec3(0,2,0);

    auto renderToScreen = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    };

    world.setCamera(camera);
    world.add(planeEntity);
    world.add(boxEntity);
    core.addProcess(renderToScreen, "render");
    core.addProcess(&control.update, "update");

    core.addProcess({
        if (core.getKey().justPressed(KeyButton.Escape)) {
            core.end();
        }
    }, "a");

    core.start();
}
