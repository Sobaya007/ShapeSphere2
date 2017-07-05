module examples.mouse;

import sbylib;
import std.stdio;

alias Sphere = MeshTemp!(GeometrySphereUV, ConditionalMaterial!(LambertMaterial, NormalMaterial));
alias Po = MeshTemp!(GeometryNT, ConditionalMaterial!(LambertMaterial, LambertMaterial));

void mainMouse() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getRenderTarget();
    auto world = new World;
    auto camera =  new PerspectiveCamera(1, 120, 0.1, 100);
    auto sphere = new Sphere(SphereUV.create(0.5));
    auto mouse = new Mouse(window);
    auto colgeom = new CollisionPolygon(vec3(0.8, 0.6, 0), vec3(-0.5, -0.2, 0), vec3(0.7, -0.8, 0));
    auto obj = new Object3D();
    auto colMesh = new CollisionEntry(colgeom, obj);
    auto mesh = new Po(colgeom.createGeometry(), obj);
    auto control = new BasicControl(mouse, colMesh);

    auto render = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        world.render(screen);
    };

    auto ray = new CollisionRay();
    auto mouseUpdate = delegate(Process proc) {
        control.update();
    };
    camera.getObj().pos.z = 4;
    camera.getObj().lookAt(vec3(0));
    world.camera = camera;
    control.camera = camera;
    sphere.createCollisionPolygons();
    world.addMesh(mesh);
    //world.addMesh(sphere);
    world.addColMeshAsPolygon(sphere);
    screen.clearColor = vec4(0.2);
    core.addProcess(render, "render");
    core.addProcess(mouseUpdate, "mouse");
    mesh.mat.ambient1 = vec3(0.2, 0, 0);
    mesh.mat.ambient2 = vec3(0.5);


    core.start();
}
