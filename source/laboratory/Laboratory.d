module laboratory.Laboratory;

import sbylib;
import laboratory.LaboratoryConsole;

void laboratoryMain() {
    auto universe = Universe.createFromJson!(
        DefineMaterialList!(
            DefineMaterial!(ShaderMaterial!q{{"baseName" : "LaboratoryWall"}}, "LaboratoryWall")
        )
    )(ResourcePath("world/laboratory.json"));
    auto world = universe.getWorld("world").unwrap();

    auto box = makeEntity(Box.create(), new NormalMaterial);
    box.pos = vec3(0,2,0);
    world.add(box);

    auto console = LaboratoryConsole.add(world);

    universe.justPressed(KeyButton.KeyI).add({
        console.on();
    });
    universe.justPressed(KeyButton.KeyG).add({
    });

    auto touchManager = new TouchManager(world);
    auto renderer = universe.findRendererByWorld(world).wrapCast!(PostProcessRenderer).unwrap();
    auto prog = renderer.getProgram();
    auto colorTexture = new utexture("colorTexture", Core().getWindow().getScreen().getColorTexture(0));
    auto referenceTexture = new utexture("referenceTexture", Core().getWindow().getScreen().getColorTexture(1));
    auto id = new TypedUniform!int("value", -1);
    auto uniforms = cast(Uniform[])[colorTexture, referenceTexture, id];
    Core().addProcess({
        prog.applyAllUniform(uniforms);
    }, "po");
    universe.justPressed(MouseButton.Button1).add({
        touchManager.getEntity(universe.mousePos)
        .fmapAnd!((Entity e) => e.getID())
        .apply!((ID i) {
            id = i;
            prog.applyAllUniform(uniforms);
        });
    });

    Core().start();
}
