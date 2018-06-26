module examples.BlitsExample;

import sbylib;

void blitsExample() {
    
    auto worldList = createFromJson(ResourcePath("world/blits.json"));

    auto world = worldList.at("world3D").get().world;
    auto target = worldList.at("world3D").get().target;

    auto planeEntity = makeEntity(
        Plane.create,
        new CheckerMaterial!(ColorMaterial, ColorMaterial)
    );
    planeEntity.color1 = vec4(1);
    planeEntity.color2 = vec4(vec3(0.5), 1);
    planeEntity.size = 0.015; /* Checker Size (in UV) */
    planeEntity.scale = vec3(100);
    world.add(planeEntity);


    CameraControl.attach(world.camera);

    Core().addProcess({
        target.blitsTo(Core().getWindow().getScreen(), BufferBit.Color);
    }, "blits");

    Core().start();
}
