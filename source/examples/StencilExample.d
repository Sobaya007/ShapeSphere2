module examples.StencilExample;

import sbylib;

void stencilExample() {
    
    auto universe = Universe.createFromJson(ResourcePath("world/stencil.json"));

    Core().start();
}
