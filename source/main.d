import std.stdio;

import sbylib;

import derelict.opengl;

void main() {
    auto world = new SbyWorld();
    auto vertices = [new VertexN(vec3(0))];
    auto faces = [new Face([0,0,0])];
    auto mesh = new Mesh();

    world.setFPS(60);
    world.start();
}
