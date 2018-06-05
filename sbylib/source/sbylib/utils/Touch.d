module sbylib.utils.Touch;

import sbylib;

class TouchManager {

    alias Callback = void delegate(Entity);

    private World world;
    private Callback callback;

    this(World world, Callback callback) {
        this.world = world;
        this.callback = callback;
    }

    void exec(vec2 pos = Core().getMouse().getPos()) {
        auto ray = CollisionRay.get(pos, world.getCamera());
        auto r = this.world.rayCast(ray);
        r.apply!(r => callback(r.entity()));
    }
}

void makeTouchable(Entity e) {
    e.buildBVH();
}

