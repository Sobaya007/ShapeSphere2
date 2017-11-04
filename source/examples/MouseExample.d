module examples.MouseExample;

import sbylib;
import std.stdio;
import std.algorithm;
import std.array;

alias PlaneEntity = EntityTemp!(GeometryPlane, ConditionalMaterial!(LambertMaterial, LambertMaterial));
alias CapsuleEntity = EntityTemp!(GeometryNT, ConditionalMaterial!(LambertMaterial, LambertMaterial));

void mouseExample() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getScreen();
    auto renderer = new Renderer();
    auto viewport = new AutomaticViewport(window);
    auto world = new World;
    auto camera =  new PerspectiveCamera(1, 120.deg, 0.1, 100);
    auto mouse = new Mouse(window);
    auto polyEntity = new PlaneEntity(Plane.create());
    polyEntity.createCollisionPolygon();
    polyEntity.obj.rot = mat3.rotFromTo(vec3(0,1,0), vec3(0,0,1));

    auto colCapGeom = new CollisionCapsule(0.2, vec3(0,-1,0), vec3(0,1,0));
    auto capGeom = colCapGeom.createGeometry();
    auto capEntity = new CapsuleEntity(capGeom, colCapGeom);
    auto control = new BasicControl(mouse, world, camera);

    auto render = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    };

    auto mouseUpdate = delegate(Process proc) {
        control.update();
    };
    CollisionRay ray = new CollisionRay();
    auto detect = delegate(Process proc) {
        Utils.getRay(mouse.getPos(), camera, ray);
        auto colInfo = world.rayCast(ray);
        if (colInfo.isNone) return;
        polyEntity.getMesh().mat.condition = colInfo.get.entity.getRootParent() is polyEntity;
        capEntity.getMesh().mat.condition  = colInfo.get.entity.getRootParent() is capEntity;
    };
    camera.getObj().pos.z = 4;
    camera.getObj().lookAt(vec3(0));
    world.setCamera(camera);
    world.add(polyEntity);
    world.add(capEntity);
    screen.setClearColor(vec4(0.2));
    core.addProcess(render, "render");
    core.addProcess(mouseUpdate, "mouse");
    core.addProcess(detect, "detect");
    polyEntity.getMesh().mat.ambient1 = vec3(0.2, 0, 0);
    polyEntity.getMesh().mat.ambient2 = vec3(0.5);
    capEntity.getMesh().mat.ambient1 = vec3(0, 0, 0.2);
    capEntity.getMesh().mat.ambient2 = vec3(0.5);

    core.start();
}
