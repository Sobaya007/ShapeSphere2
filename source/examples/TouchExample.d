module examples.TouchExample;

import sbylib;

void touchExample() {
    
    auto universe = Universe.createFromJson(ResourcePath("world/touch.json"));
    auto world = universe.getWorld("world").unwrap();

    ID id;
    auto touchManager = new TouchManager(world);
    universe.isPressed(MouseButton.Button1).add({
        auto entity = touchManager.getEntity(universe.mousePos);
        Core().getWindow().setTitle(entity.name.toString);

        entity.fmapAnd!((Entity e) => e.getID()).apply!((ID i) {
            id = i;
        });
    });

    auto renderer = universe.findRendererByWorld(world).wrapCast!(PostProcessRenderer).unwrap();
    auto prog = renderer.getProgram();
    Core().addProcess({
        auto screen = Core().getWindow().getScreen();
        prog.applyAllUniform(cast(Uniform[])[
            new utexture("colorTexture", screen.getColorTexture(0)),
            new utexture("referenceTexture", screen.getColorTexture(1)),
            new TypedUniform!int("value", id)
        ]);
    }, "post");

    Core().start();
}
