module examples.MaterialExample;

import sbylib;
import std.stdio;

alias Check = CheckerMaterial!(LambertMaterial, LambertMaterial);
alias Check2 = CheckerMaterial!(Check, Check);
alias Check4 = CheckerMaterial!(Check2, Check2);

void materialExample() {

    auto universe = Universe.createFromJson!(
        DefineMaterialList!(
            DefineMaterial!(Check4, "Check")
        )
    )(ResourcePath("world/material.json"));
    auto world = universe.getWorld("world").get();

    auto plane = world.findByName("plane")
        .wrapRange()
        .wrapCast!(TypedEntity!(GeometryPlane, Check4))
        .get();
    plane.size = 0.02;
    plane.size1 = 0.01;
    plane.size2 = 0.01;
    plane.size11 = 0.005;
    plane.size12 = 0.005;
    plane.size21 = 0.005;
    plane.size22 = 0.005;
    plane.ambient111 = vec3(0.5, 0.2, 0.2);
    plane.ambient112 = vec3(0.2, 0.5, 0.2);
    plane.ambient121 = vec3(0.2, 0.2, 0.5);
    plane.ambient122 = vec3(0.5, 0.5, 0.5);
    plane.ambient211 = vec3(0.8, 0.5, 0.5);
    plane.ambient212 = vec3(0.5, 0.8, 0.5);
    plane.ambient221 = vec3(0.5, 0.5, 0.8);
    plane.ambient222 = vec3(0.8, 0.8, 0.8);


    Core().start();
}
