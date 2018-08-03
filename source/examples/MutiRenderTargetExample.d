module examples.MultiRenderTargetExample;

import sbylib;

void multiRenderTargetExample() {

    alias NormalUvMaterial = ShaderMaterial!(q{ {"baseName" : "NormalUvMaterial"}});
    
    auto universe = Universe.createFromJson!(
        DefineMaterialList!(
            DefineMaterial!(NormalUvMaterial, "NormalUvMaterial")
        )
    )(ResourcePath("world/mrt.json"));

    auto target = universe.getTarget("target").wrapCast!(RenderTarget).unwrap();

    universe.addProcess({
        auto tex = target.getColorTexture(1);
        auto screen = Core().getWindow().getScreen();
        blitsTo(tex, screen, 0, 0, screen.width/2, screen.height);
    }, "blits");
    Core().start();
}
