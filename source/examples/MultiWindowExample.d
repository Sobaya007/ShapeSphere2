module examples.MultiWindowExample;

import sbylib;
import std.stdio;

void multiWindowExample() {

    Universe.createFromJson(ResourcePath("world/multiWindow.json"));

    Core().start();
}
