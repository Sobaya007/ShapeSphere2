module examples.mouse;

import sbylib;
import std.stdio;
import std.algorithm;
import std.array;

alias PlaneEntity = EntityTemp!(GeometryPlane, ConditionalMaterial!(LambertMaterial, LambertMaterial));
alias CapsuleEntity = EntityTemp!(GeometryNT, ConditionalMaterial!(LambertMaterial, LambertMaterial));

void mainMouse() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getRenderTarget();
    auto world = new Bahamut;
    auto camera =  new PerspectiveCamera(1, 120, 0.1, 100);
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
        world.render(screen);
    };

    auto mouseUpdate = delegate(Process proc) {
        control.update();
    };
    CollisionRay ray = new CollisionRay();
    auto detect = delegate(Process proc) {
        Utils.getRay(mouse.getPos(), camera, ray);
        auto colInfos = world.calcCollideRay(ray).filter!(a => a.collided).array;
        if (colInfos.length == 0) return;
        auto colInfo = colInfos.minElement!(a => a.colDist);
        polyEntity.mat.condition = colInfo.colEntry.getOwner().getRootParent() is polyEntity;
        capEntity.mat.condition = colInfo.colEntry.getOwner().getRootParent() is capEntity;
    };
    camera.getObj().pos.z = 4;
    camera.getObj().lookAt(vec3(0));
    world.camera = camera;
    world.add(polyEntity);
    world.add(capEntity);
    screen.clearColor = vec4(0.2);
    core.addProcess(render, "render");
    core.addProcess(mouseUpdate, "mouse");
    core.addProcess(detect, "detect");
    polyEntity.mat.ambient1 = vec3(0.2, 0, 0);
    polyEntity.mat.ambient2 = vec3(0.5);
    capEntity.mat.ambient1 = vec3(0, 0, 0.2);
    capEntity.mat.ambient2 = vec3(0.5);

    core.start();
}
