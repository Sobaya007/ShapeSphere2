module examples.mouse;

import sbylib;
import std.stdio;

alias PlaneMesh = MeshTemp!(GeometryPlane, ConditionalMaterial!(LambertMaterial, LambertMaterial));

void mainMouse() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getRenderTarget();
    auto world = new Bahamut;
    auto camera =  new PerspectiveCamera(1, 120, 0.1, 100);
    auto mouse = new Mouse(window);
    auto polyGeom = Plane.create();
    auto polyMesh = new PlaneMesh(polyGeom);
    auto polyEntity = new Entity;
    polyEntity.setMesh(polyMesh);
    polyEntity.createCollisionPolygon();

    auto colCapGeom = new CollisionCapsule(0.2, vec3(0,-1,0), vec3(0,1,0));
    auto colCap = new CollisionEntry(colCapGeom);
    auto capGeom = colCapGeom.createGeometry();
    auto capMesh = new MeshTemp!(GeometryNT, ConditionalMaterial!(LambertMaterial, LambertMaterial))(capGeom);
    auto capEntity = new Entity;
    capEntity.setMesh(capMesh);
    capEntity.setCollisionEntry(colCap);
    auto control = new BasicControl(mouse, world, camera);

    auto render = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        world.render(screen);
    };

    auto mouseUpdate = delegate(Process proc) {
        control.update();
    };
    camera.getObj().pos.z = 4;
    camera.getObj().lookAt(vec3(0));
    world.camera = camera;
    world.add(polyEntity);
    world.add(capEntity);
    screen.clearColor = vec4(0.2);
    core.addProcess(render, "render");
    core.addProcess(mouseUpdate, "mouse");
    polyMesh.mat.ambient1 = vec3(0.2, 0, 0);
    polyMesh.mat.ambient2 = vec3(0.5);
    capMesh.mat.ambient1 = vec3(0, 0, 0.2);
    capMesh.mat.ambient2 = vec3(0.5);
    //foreach (entry; polyMesh.geom.getCollisionPolygons) {
    //    entry.setOnCollide((CollisionInfo info) {
    //        polyMesh.mat.condition = info.collided;
    //    });
    //}
    //colCap.setOnCollide((CollisionInfo info) {
    //    capMesh.mat.condition = info.collided;
    //});

    core.start();
}
