module examples.BasicExample;

import sbylib;

void basicExample() {
    auto core = Core();
    auto window = core.getWindow();
    auto world = new World;


    auto camera = new PerspectiveCamera(
            window.width / window.height, /* Aspect Ratio   */
            60.deg, /* FOV (in angle) */
            0.1, /* Near Clip      */
            100, /* Far Clip       */);
    camera.pos = vec3(3, 2, 9);
    camera.lookAt(vec3(0,2,0));
    world.configure3D(camera);


    auto planeEntity = makeEntity(
            Plane.create(100,100), /* width, height */
            new CheckerMaterial!(LambertMaterial, LambertMaterial)
    );
    planeEntity.ambient1 = vec3(1);
    planeEntity.ambient2 = vec3(0.5);
    planeEntity.size = 0.015; /* Checker Size (in UV) */
    world.add(planeEntity);


    auto boxEntity = makeEntity(Box.create(), new NormalMaterial);
    boxEntity.pos = vec3(0,2,0);
    boxEntity.scale = vec3(4);
    world.add(boxEntity);


    core.getKey().justPressed(KeyButton.Escape).add(() => core.end);


    core.start();
}
