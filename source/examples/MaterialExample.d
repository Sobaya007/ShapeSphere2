module examples.MaterialExample;

import sbylib;
import std.stdio;

alias Check = CheckerMaterial!(LambertMaterial, LambertMaterial);
alias Check2 = CheckerMaterial!(Check, Check);
alias Check4 = CheckerMaterial!(Check2, Check2);

void materialExample() {
    auto core = Core();
    auto window = core.getWindow();
    auto world = new World;
    auto renderer = new Renderer();
    auto viewport = new AutomaticViewport(window);


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


    auto polyEntity = makeEntity(Plane.create(10,10), new Check4);
    polyEntity.mat.size = 0.02;
    polyEntity.mat.size1 = 0.01;
    polyEntity.mat.size2 = 0.01;
    polyEntity.mat.size11 = 0.005;
    polyEntity.mat.size12 = 0.005;
    polyEntity.mat.size21 = 0.005;
    polyEntity.mat.size22 = 0.005;
    polyEntity.mat.ambient111 = vec3(0.5, 0.2, 0.2);
    polyEntity.mat.ambient112 = vec3(0.2, 0.5, 0.2);
    polyEntity.mat.ambient121 = vec3(0.2, 0.2, 0.5);
    polyEntity.mat.ambient122 = vec3(0.5, 0.5, 0.5);
    polyEntity.mat.ambient211 = vec3(0.8, 0.5, 0.5);
    polyEntity.mat.ambient212 = vec3(0.5, 0.8, 0.5);
    polyEntity.mat.ambient221 = vec3(0.5, 0.5, 0.8);
    polyEntity.mat.ambient222 = vec3(0.8, 0.8, 0.8);
    world.add(polyEntity);


    auto control = new CameraControl(camera);
    core.addProcess(&control.update, "update");


    core.getKey().justPressed(KeyButton.Escape).add(&core.end);


    core.addProcess({
        screen.clear(ClearMode.Color, ClearMode.Depth);
        renderer.render(world, screen, viewport);
    }, "render");


    core.start();
}
