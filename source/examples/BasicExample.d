module examples.BasicExample;

import sbylib;

void basicExample() {
    
    auto worldList = createFromJson(ResourcePath("world/basic.json"));

    auto world = worldList.at("world3D").get().world;

    auto planeEntity = makeEntity(
        Plane.create,
        new CheckerMaterial!(ColorMaterial, ColorMaterial)
    );
    planeEntity.color1 = vec4(1);
    planeEntity.color2 = vec4(vec3(0.5), 1);
    planeEntity.size = 0.015; /* Checker Size (in UV) */
    planeEntity.scale = vec3(100);
    world.add(planeEntity);


    Core().start();
}
