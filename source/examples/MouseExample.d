module examples.MouseExample;

import sbylib;

void mouseExample() {
    auto core = Core();
    auto window = core.getWindow();
    auto world = new World;
    auto renderer = new Renderer();
    auto viewport = new AutomaticViewport(window);
    auto mouse = new ViewportMouse(viewport);


    auto screen = window.getScreen();
    screen.setClearColor(vec4(0.2));


    auto camera = new PerspectiveCamera(
            window.getWidth() / window.getHeight(), /* Aspect Ratio   */
            60.deg, /* FOV (in angle) */
            0.1, /* Near Clip      */
            100, /* Far Clip       */);
    camera.pos = vec3(1,2,4);
    camera.lookAt(vec3(0));
    world.setCamera(camera);


    alias MyMaterial = ConditionalMaterial!(LambertMaterial, LambertMaterial);


    auto polyEntity = makeEntity(Plane.create(), new MyMaterial);
    polyEntity.buildBVH();
    polyEntity.rot = mat3.rotFromTo(vec3(0,1,0), vec3(0,0,1));
    polyEntity.ambient1 = vec3(0.2, 0, 0);
    polyEntity.ambient2 = vec3(0.5);
    world.add(polyEntity);


    auto colCapGeom = new CollisionCapsule(0.2, vec3(0,-1,0), vec3(0,1,0));
    auto capGeom = colCapGeom.createGeometry();
    auto capEntity = makeEntity(capGeom, new MyMaterial, colCapGeom);
    capEntity.ambient1 = vec3(0, 0, 0.2);
    capEntity.ambient2 = vec3(0.5);
    world.add(capEntity);


    auto ray = new CollisionRay();
    core.addProcess({
        ray.build(mouse.getPos(), camera);
        auto colInfo = world.rayCast(ray);
        if (colInfo.isNone) return;
        polyEntity.condition = colInfo.get.entity.getRootParent() is polyEntity;
        capEntity.condition  = colInfo.get.entity.getRootParent() is capEntity;
    }, "detect");


    auto control = new BasicControl(mouse, world, camera);
    core.addProcess(&control.update, "mouse");


    core.getKey().justPressed(KeyButton.Escape).add(&core.end);


    core.addProcess({
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    }, "render");


    core.start();
}
