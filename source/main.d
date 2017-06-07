import std.stdio;

import sbylib;

void main() {
    auto world = new SbyWorld();
    world.setFPS(60);
    world.start();
}
