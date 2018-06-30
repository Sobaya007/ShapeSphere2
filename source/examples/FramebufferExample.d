module examples.FramebufferExample;

import sbylib;

void framebufferExample() {
    auto universe = Universe.createFromJson(ResourcePath("world/frameBuffer.json"));
    auto world = universe.getWorld("world").get();
    auto internalWorld = universe.getWorld("internalWorld").get();


    auto renderTarget = 
        universe.getTarget("target")
        .wrapCast!RenderTarget
        .get();


    auto box = world.findByName("box")
        .wrapRange
        .get()
        .mesh.mat
        .wrapCast!(TextureMaterial)
        .get();
    box.texture = renderTarget.getColorTexture;


    auto box2 = internalWorld.findByName("box2")
        .wrapRange
        .get();
    box2.addProcess({ box2.rot *= mat3.axisAngle(vec3(1,1,1).normalize, 0.02.rad); });


    Core().start();
}
