module examples.XFileLoadExample;

import sbylib;

import model.xfile.loader;

void xFileLoadExample() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getScreen();
    auto world = new World;
    auto renderer = new Renderer();
    auto viewport = new AutomaticViewport(window);
    auto xLoader = new XLoader;


    auto camera = new PerspectiveCamera(
            window.getWidth() / window.getHeight(), /* Aspect Ratio   */
            120.deg, /* FOV (in angle) */
            0.1, /* Near Clip      */
            100, /* Far Clip       */);
    camera.pos = vec3(0, 2, 15);
    camera.lookAt(vec3(0, 2, 0));
    world.setCamera(camera);


    auto planeEntity = makeEntity(
            Plane.create(100,100), /* width, height */
            new CheckerMaterial!(LambertMaterial, LambertMaterial)
    );
    planeEntity.ambient1 = vec3(1);
    planeEntity.ambient2 = vec3(0.5);
    planeEntity.size = 0.015; /* Checker Size (in UV) */
    world.add(planeEntity);


    auto texCube = xLoader.load(ModelPath("texCube.x"), true, true, true).buildEntity();
    texCube.pos = vec3(-2, 3, 0);
    world.add(texCube);


    auto sphere = xLoader.load(ModelPath("sphere.x"), true, true, false).buildEntity();
    sphere.pos = vec3(-4, 3, 0);
    world.add(sphere);


    auto parentEntity = xLoader.load(ModelPath("parent.x"), true, true, false).buildEntity();
    parentEntity.pos = vec3(2, 2, 0);
    world.add(parentEntity);


    auto pointLight = new PointLight(vec3(10), vec3(1));
    world.add(pointLight);


    auto control = new CameraControl(camera);
    core.addProcess(&control.update, "update");


    core.getKey().justPressed(KeyButton.Escape).add(() => core.end);


    core.addProcess({
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    }, "render");

    core.start();

}
