module examples.MultiRenderTargetExample;

import sbylib;

void multiRenderTargetExample() {

    alias NormalUvMaterial = ShaderMaterial!(q{ {"baseName" : "NormalUvMaterial"}});
    
    auto universe = Universe.createFromJson!(
        DefineMaterialList!(
            DefineMaterial!(NormalUvMaterial, "NormalUvMaterial")
        )
    )(ResourcePath("world/mrt.json"));

    auto screen = Core().getWindow().getScreen();

    // because Color1 is used as ID buffer
    screen.attachTexture!(ubyte)(FramebufferAttachType.Color2);

    universe.addProcess({
        auto tex = screen.getColorTexture(2);
        blitsTo(tex, screen, 0, 0, screen.width/2, screen.height);
    }, "blits");
    Core().start();
}
