module examples.material;

import sbylib;
import std.stdio;

alias Check = CheckerMaterial!(LambertMaterial, LambertMaterial);
alias Check2 = CheckerMaterial!(Check, Check);
alias Check4 = CheckerMaterial!(Check2, Check2);

alias PlaneMesh = MeshTemp!(GeometryPlane,Check4);

void mainMaterial() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getRenderTarget();
    auto world = new Bahamut;
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
    world.add(polyMesh);
    screen.clearColor = vec4(0.2);
    core.addProcess(render, "render");
    polyMesh.obj.lookTo(vec3(0,1,0), vec3(0,0,1));
    polyMesh.mat.size = 0.02;
    polyMesh.mat.size1 = 0.01;
    polyMesh.mat.size2 = 0.01;
    polyMesh.mat.size11 = 0.005;
    polyMesh.mat.size12 = 0.005;
    polyMesh.mat.size21 = 0.005;
    polyMesh.mat.size22 = 0.005;
    polyMesh.mat.ambient111 = vec3(0.5, 0.2, 0.2);
    polyMesh.mat.ambient112 = vec3(0.2, 0.5, 0.2);
    polyMesh.mat.ambient121 = vec3(0.2, 0.2, 0.5);
    polyMesh.mat.ambient122 = vec3(0.5, 0.5, 0.5);
    polyMesh.mat.ambient211 = vec3(0.8, 0.5, 0.5);
    polyMesh.mat.ambient212 = vec3(0.5, 0.8, 0.5);
    polyMesh.mat.ambient221 = vec3(0.5, 0.5, 0.8);
    polyMesh.mat.ambient222 = vec3(0.8, 0.8, 0.8);

    core.start();
}
