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


    auto screen = window.getScreen();
    screen.setClearColor(vec4(0.2));


    auto camera = new PerspectiveCamera(
            window.width / window.height, /* Aspect Ratio   */
            60.deg, /* FOV (in angle) */
            0.1, /* Near Clip      */
            100, /* Far Clip       */);
    camera.pos = vec3(1,2,4);
    camera.lookAt(vec3(0));
    world.configure3D(camera);


    auto polyEntity = makeEntity(Plane.create(10,10), new Check4);
    polyEntity.size = 0.02;
    polyEntity.size1 = 0.01;
    polyEntity.size2 = 0.01;
    polyEntity.size11 = 0.005;
    polyEntity.size12 = 0.005;
    polyEntity.size21 = 0.005;
    polyEntity.size22 = 0.005;
    polyEntity.ambient111 = vec3(0.5, 0.2, 0.2);
    polyEntity.ambient112 = vec3(0.2, 0.5, 0.2);
    polyEntity.ambient121 = vec3(0.2, 0.2, 0.5);
    polyEntity.ambient122 = vec3(0.5, 0.5, 0.5);
    polyEntity.ambient211 = vec3(0.8, 0.5, 0.5);
    polyEntity.ambient212 = vec3(0.5, 0.8, 0.5);
    polyEntity.ambient221 = vec3(0.5, 0.5, 0.8);
    polyEntity.ambient222 = vec3(0.8, 0.8, 0.8);
    world.add(polyEntity);


    CameraControl.attach(camera);


    core.getKey().justPressed(KeyButton.Escape).add(() => core.end);



    core.start();
}
