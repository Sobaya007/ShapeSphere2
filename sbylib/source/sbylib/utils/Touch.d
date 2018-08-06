module sbylib.utils.Touch;

import sbylib;

class TouchManager {

    private World world;
    private float[] buf;

    this(World world) {
        this.world = world;
        this.buf = new float[Core().getWindow().width*Core().getWindow().height];
    }

    Maybe!Entity getEntity(vec2 pos) {
        auto id = getID(pos);
        return world.findByID(id).wrapRange();
    }

    private ID getID(vec2 pos) {
        auto texture = Core().getWindow().getScreen().getColorTexture(1);
        pos = (pos + 1) / 2 * Core().getWindow().size;
        texture.blitsTo(buf.ptr, ImageFormat.R);
        return cast(ID)buf[cast(size_t)(pos.x + pos.y * Core().getWindow().width)];
    }
}
