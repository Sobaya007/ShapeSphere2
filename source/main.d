import std.stdio;

import sbylib;

void main() {
    auto world = new SbyWorld();
    world.setFPS(60);
    world.start();

    auto vertices = [new VertexN(vec3(0))];
    auto faces = [new Face([0,0,0])];

    new Geometry!([Attribute(3, "normal")], Prim.Triangle)(vertices, faces);
}
