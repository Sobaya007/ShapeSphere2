module examples.mouse;

import sbylib;
import std.stdio;

alias PlaneMesh = MeshTemp!(GeometryPlane, ConditionalMaterial!(LambertMaterial, LambertMaterial));

void mainMouse() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getRenderTarget();
    auto world = new World;
    auto camera =  new PerspectiveCamera(1, 120, 0.1, 100);
    auto mouse = new Mouse(window);
    auto polyGeom = Plane.create();
    auto mesh = new PlaneMesh(polyGeom);
    auto control = new BasicControl(mouse, world);

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
    world.addMesh(mesh);
    mesh.createCollisionPolygons();
    world.addColMeshAsPolygon(mesh);
    screen.clearColor = vec4(0.2);
    core.addProcess(render, "render");
    core.addProcess(mouseUpdate, "mouse");
    mesh.mat.ambient1 = vec3(0.2, 0, 0);
    mesh.mat.ambient2 = vec3(0.5);
    foreach (entry; mesh.geom.getCollisionPolygons) {
        entry.onRayCast = (info) {
            mesh.mat.condition = info.collided;
        };
    }

    core.start();
}
