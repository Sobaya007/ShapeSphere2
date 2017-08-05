module examples.Material;

import sbylib;
import std.stdio;

alias Check = CheckerMaterial!(LambertMaterial, LambertMaterial);
alias Check2 = CheckerMaterial!(Check, Check);
alias Check4 = CheckerMaterial!(Check2, Check2);

alias PlaneEntity = EntityTemp!(GeometryPlane, Check4);

void materialExample() {
    auto core = Core();
    auto window = core.getWindow();
    auto screen = window.getRenderTarget();
    auto world = new World;
    auto camera =  new PerspectiveCamera(1, 120, 0.1, 100);
    auto polyEntity = new PlaneEntity(Plane.create(10,10));

    auto render = delegate (Process proc) {
        screen.clear(ClearMode.Color, ClearMode.Depth);
        world.render(screen);
    };

    camera.getObj().pos = vec3(1,2,4);
    camera.getObj().lookAt(vec3(0));
    world.setCamera(camera);
    world.add(polyEntity);
    screen.clearColor = vec4(0.2);
    core.addProcess(render, "render");
    polyEntity.getMesh().mat.size = 0.02;
    polyEntity.getMesh().mat.size1 = 0.01;
    polyEntity.getMesh().mat.size2 = 0.01;
    polyEntity.getMesh().mat.size11 = 0.005;
    polyEntity.getMesh().mat.size12 = 0.005;
    polyEntity.getMesh().mat.size21 = 0.005;
    polyEntity.getMesh().mat.size22 = 0.005;
    polyEntity.getMesh().mat.ambient111 = vec3(0.5, 0.2, 0.2);
    polyEntity.getMesh().mat.ambient112 = vec3(0.2, 0.5, 0.2);
    polyEntity.getMesh().mat.ambient121 = vec3(0.2, 0.2, 0.5);
    polyEntity.getMesh().mat.ambient122 = vec3(0.5, 0.5, 0.5);
    polyEntity.getMesh().mat.ambient211 = vec3(0.8, 0.5, 0.5);
    polyEntity.getMesh().mat.ambient212 = vec3(0.5, 0.8, 0.5);
    polyEntity.getMesh().mat.ambient221 = vec3(0.5, 0.5, 0.8);
    polyEntity.getMesh().mat.ambient222 = vec3(0.8, 0.8, 0.8);

    core.start();
}
