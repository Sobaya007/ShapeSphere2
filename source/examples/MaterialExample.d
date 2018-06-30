module examples.MaterialExample;

import sbylib;
import std.stdio;

alias Check = CheckerMaterial!(LambertMaterial, LambertMaterial);
alias Check2 = CheckerMaterial!(Check, Check);
alias Check4 = CheckerMaterial!(Check2, Check2);

void materialExample() {

    auto universe = Universe.createFromJson(ResourcePath("world/material.json"));
    auto world = universe.getWorld("world").get();

    auto polyEntity = makeEntity(Plane.create(10,10), new Check4);
    polyEntity.size = 0.02;
    polyEntity.size1 = 0.01;
    polyEntity.size2 = 0.01;
    polyEntity.size11 = 0.005;
    polyEntity.size12 = 0.005;
    polyEntity.size21 = 0.005;
    polyEntity.size22 = 0.005;
    polyEntity.ambient111 = vec3(0.5, 0.2, 0.2);
    polyEntity.ambient112 = vec3(0.2, 0.5, 0.2);
    polyEntity.ambient121 = vec3(0.2, 0.2, 0.5);
    polyEntity.ambient122 = vec3(0.5, 0.5, 0.5);
    polyEntity.ambient211 = vec3(0.8, 0.5, 0.5);
    polyEntity.ambient212 = vec3(0.5, 0.8, 0.5);
    polyEntity.ambient221 = vec3(0.5, 0.5, 0.8);
    polyEntity.ambient222 = vec3(0.8, 0.8, 0.8);
    world.add(polyEntity);


    Core().start();
}
