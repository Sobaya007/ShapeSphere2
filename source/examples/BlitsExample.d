module examples.BlitsExample;

import sbylib;

void blitsExample() {
    
    Universe.createFromJson(ResourcePath("world/blits.json"));

    Core().start();
}
