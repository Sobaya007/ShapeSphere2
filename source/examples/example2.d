module examples.example2;

import sbylib;

void example2() {
    auto core = Core();

    auto world = new Bahamut;

    auto screen = core.getWindow().getRenderTarget();

    auto camera = new PerspectiveCamera(
            1,   /* Aspect Ratio   */
            120, /* FOV (in angle) */
            0.1, /* Near Clip      */
            100, /* Far Clip       */);
    camera.getObj().pos = vec3(3, 2, 9);
    camera.getObj().lookAt(vec3(0,2,0));

    auto planeGeom = Plane.create(100, 100); /* width, height */

    auto planeMat = new CheckerMaterial!(LambertMaterial, LambertMaterial);
    planeMat.ambient1 = vec3(1);
    planeMat.ambient2 = vec3(0.5);
    planeMat.size = 0.015; /* Checker Size (in UV) */

    auto planeEntity = new Entity(planeGeom, planeMat);

    auto renderToScreen = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        world.render(core.getWindow().getRenderTarget());
    };

    world.camera = camera;
    world.add(planeEntity);
    core.addProcess(renderToScreen, "render");

    core.start();
}
