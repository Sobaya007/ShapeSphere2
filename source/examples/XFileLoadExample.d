module examples.XFileLoadExample;

import sbylib;

import model.xfile.loader;

void xFileLoadExample() {
    auto core = Core();

    auto world = new World;

    auto window = core.getWindow();

    auto screen = window.getScreen();

    auto renderer = new Renderer();

    auto viewport = new AutomaticViewport(window);

    Camera camera = new PerspectiveCamera(
            window.getWidth() / window.getHeight(), /* Aspect Ratio   */
            120.deg, /* FOV (in angle) */
            0.1, /* Near Clip      */
            100, /* Far Clip       */);
    camera.pos = vec3(0, 2, 15);
    camera.lookAt(vec3(0, 2, 0));

    auto control = new CameraControl(core.getKey(), core.getMouse(), camera);

    auto planeGeom = Plane.create(100, 100); /* width, height */

    auto planeMat = new CheckerMaterial!(LambertMaterial, LambertMaterial);
    planeMat.ambient1 = vec3(1);
    planeMat.ambient2 = vec3(0.5);
    planeMat.size = 0.015; /* Checker Size (in UV) */

    auto planeEntity = new Entity(planeGeom, planeMat);

    // ---

    XLoader xLoader = new XLoader;

    Entity texCubeEntity = xLoader.load(ModelPath("test.x"), true, true, true).buildEntity();
    texCubeEntity.obj.pos = vec3(-2, 3, 0);

    //Entity sphereEntity = xLoader.load(ModelPath("sphere.x"), true, true, false).buildEntity();
    //sphereEntity.obj.pos = vec3(-4, 3, 0);

    //Entity parentEntity = xLoader.load(ModelPath("parent.x"), true, true, false).buildEntity();
    //parentEntity.obj.pos = vec3(2, 2, 0);


    // auto boxGeom = Box.create(10, 10, 10); /* width, height, depth */
    // auto boxMat = new LambertMaterial;
    // boxMat.diffuse = vec3(0, 0.4, 0.8);
    // auto boxEntity = new Entity(boxGeom, boxMat);
    // boxEntity.obj.pos = vec3(2,3,0);

    PointLight pointLight;
    pointLight.pos = vec3(10,10,10);
    pointLight.diffuse = vec3(1);
    world.addPointLight(pointLight);

    // ---


    auto renderToScreen = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    };

    world.setCamera(camera);
    world.add(planeEntity);
    world.add(texCubeEntity);
    //world.add(sphereEntity);
    //world.add(parentEntity);
    // world.add(boxEntity);
    core.addProcess(renderToScreen, "render");
    core.addProcess(&control.update, "update");

    core.start();
}
