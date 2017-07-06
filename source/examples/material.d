module examples.material;

import sbylib;
import std.stdio;

alias PlaneMesh = MeshTemp!(GeometryPlane,
        CheckerMaterial!(
            CheckerMaterial!(LambertMaterial, LambertMaterial),
            CheckerMaterial!(NormalMaterial, UvMaterial)));

void mainMaterial() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getRenderTarget();
    auto world = new World;
    auto camera =  new PerspectiveCamera(1, 120, 0.1, 100);
    auto polyGeom = Plane.create(10,10);
    auto polyMesh = new PlaneMesh(polyGeom);

    auto render = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        world.render(screen);
    };

    camera.getObj().pos = vec3(1,2,4);
    camera.getObj().lookAt(vec3(0));
    world.camera = camera;
    world.addMesh(polyMesh);
    screen.clearColor = vec4(0.2);
    core.addProcess(render, "render");
    polyMesh.obj.lookTo(vec3(0,1,0), vec3(0,0,1));
    polyMesh.mat.ambient11 = vec3(0.8, 0.5, 0.5);
    polyMesh.mat.ambient12 = vec3(0.8, 0.8, 0.8);
    polyMesh.mat.size = 0.02;
    polyMesh.mat.size1 = 0.015;
    polyMesh.mat.size2 = 0.01;

    core.start();
}
