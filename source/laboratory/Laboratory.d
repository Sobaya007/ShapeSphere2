module laboratory.Laboratory;

import sbylib;

void laboratoryMain() {
    auto universe = Universe.createFromJson!(
        DefineMaterialList!(
            DefineMaterial!(ShaderMaterial!q{{"baseName" : "LaboratoryWall"}}, "LaboratoryWall")
        )
    )(ResourcePath("world/laboratory.json"));
    auto world = universe.getWorld("world").unwrap();

    Core().start();
}
