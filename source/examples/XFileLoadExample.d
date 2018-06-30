module examples.XFileLoadExample;

import sbylib;

void xFileLoadExample() {

    Universe.createFromJson(ResourcePath("world/xfileLoad.json"));

    Core().start();
}
