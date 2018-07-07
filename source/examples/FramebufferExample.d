module examples.FramebufferExample;

import sbylib;

void framebufferExample() {
    auto universe = Universe.createFromJson(ResourcePath("world/frameBuffer.json"));
    auto world = universe.getWorld("world").unwrap();
    auto internalWorld = universe.getWorld("internalWorld").unwrap();


    auto renderTarget = 
        universe.getTarget("target")
        .wrapCast!RenderTarget
        .unwrap();


    auto box = world.findByName("box")
        .wrapRange
        .wrapCast!(TypedEntity!(GeometryBox, TextureMaterial))
        .unwrap();
    box.texture = renderTarget.getColorTexture;


    auto box2 = internalWorld.findByName("box2")
        .wrapRange
        .unwrap();
    box2.addProcess({ box2.rot *= mat3.axisAngle(vec3(1,1,1).normalize, 0.02.rad); });


    Core().start();
}
