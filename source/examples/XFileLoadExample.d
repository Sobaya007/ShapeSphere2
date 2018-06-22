module examples.XFileLoadExample;

import sbylib;

void xFileLoadExample() {
    auto world = createFromJson(ResourcePath("world/xfileLoad.json")).at("world3D").get().world;


    auto planeEntity = makeEntity(
            Plane.create, /* width, height */
            new CheckerMaterial!(ColorMaterial, ColorMaterial)
    );
    planeEntity.color1 = vec4(1);
    planeEntity.color2 = vec4(vec3(0.5), 1);
    planeEntity.size = 0.015; /* Checker Size (in UV) */
    planeEntity.scale = vec3(100);
    world.add(planeEntity);


    CameraControl.attach(world.camera);


    Core().start();

}
