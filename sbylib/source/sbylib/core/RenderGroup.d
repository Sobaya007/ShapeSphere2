module sbylib.core.RenderGroup;

import std.algorithm;
import std.signals;

public {
    import sbylib.entity.Entity;
    import sbylib.camera.Camera;
}

interface IRenderGroup {
    void render();
    void add(Entity);
    void remove(Entity);
    void clear();
}

class RegularRenderGroup : IRenderGroup {

    private Entity[] entities;

    override void render() {
        this.entities.each!(e => e.render());
        //import std.stdio;
        //writeln(">>>>>>>>>>");
        //this.entities.each!(e => e.writeln);
        //writeln("<<<<<<<<<<");
    }

    override void add(Entity e) {
        this.entities ~= e;
    }

    override void remove(Entity e) {
        auto num = this.entities.length;
        this.entities = this.entities.remove!(e2 => e2 == e);
        //assert(this.entities.length == num-1, e.toString);
    }

    override void clear() {
        this.entities = [];
    }
}

class TransparentRenderGroup : IRenderGroup {

    private Entity[] entities;
    private Camera camera;

    this(Camera camera) {
        this.camera = camera;
    }

    override void render() {
        this.entities.sort!((a,b) => dot(camera.pos - a.pos, camera.rot.column[2]) > dot(camera.pos - b.pos, camera.rot.column[2]));
        this.entities.each!(e => e.render());
    }

    override void add(Entity e) {
        this.entities ~= e;
    }

    override void remove(Entity e) {
        auto num = this.entities.length;
        this.entities = this.entities.remove!(e2 => e2 == e);
        assert(this.entities.length == num-1);
    }

    override void clear() {
        this.entities = [];
    }
}
