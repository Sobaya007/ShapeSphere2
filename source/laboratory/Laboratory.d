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

    auto box = makeEntity(Box.create(), new ExpandMaterial!(NormalMaterial, ColorMaterial));
    box.color = vec4(1,0,0,1);
    world.add(box);

    auto console = LaboratoryConsole.add(world);

    Core().getWindow().key.justPressed(KeyButton.KeyI).add({
        console.on();
    });

    Core().start();
}
