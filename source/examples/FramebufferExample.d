module examples.FramebufferExample;

import sbylib;

void framebufferExample() {
    auto worldList = createFromJson(ResourcePath("world/frameBuffer.json"));
    auto world = worldList.at("world3D").get().world;
    auto internalWorld = worldList.at("internalWorld").get().world;


    auto renderTarget = 
        worldList.at("internalWorld")
        .target
        .wrapCast!RenderTarget
        .get();


    auto planeEntity = makeEntity(
        Plane.create,
        new CheckerMaterial!(ColorMaterial, ColorMaterial)
    );
    planeEntity.color1 = vec4(1);
    planeEntity.color2 = vec4(vec3(0.5), 1);
    planeEntity.size = 0.015; /* Checker Size (in UV) */
    planeEntity.scale = vec3(100);
    world.add(planeEntity);


    auto boxEntity = world.findByName("boxEntity")
        .wrapRange
        .getOrError("boxEntity was not found")
        .mesh.mat
        .wrapCast!(TextureMaterial)
        .getOrError("type mismatch");
    boxEntity.texture = renderTarget.getColorTexture;


    auto boxEntity2 = internalWorld.findByName("boxEntity2")
        .wrapRange
        .get();
    boxEntity2.addProcess({ boxEntity2.rot *= mat3.axisAngle(vec3(1,1,1).normalize, 0.02.rad); });


    CameraControl.attach(world.camera);


    Core().start();
}
