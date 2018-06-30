module examples.BasicExample;

import sbylib;

void basicExample() {
    
    Universe.createFromJson(ResourcePath("world/basic.json"));

    Core().start();
}
