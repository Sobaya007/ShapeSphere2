module sbylib.core.RenderGroup;

import std.algorithm;
import std.signals;
import std.container.slist;

public {
    import sbylib.entity.Entity;
    import sbylib.camera.Camera;
}

interface IRenderGroup {
    void render();
    void add(Entity);
}

//class RegularRenderGroup : IRenderGroup {
//
//    private SList!(Entity) entities;
//
//    override void render() {
//        this.entities.each!(e => e.render());
//    }
//
//    override void add(Entity e) {
//        this.entities.insert(e);
//        e.connect({this.entities.linearRemoveElement(e);});
//    }
//}
//
//class TransparentRenderGroup : IRenderGroup {
//
//    private SList!(Entity) entities;
//    private Camera camera;
//
//    this(Camera camera) {
//        this.camera = camera;
//    }
//
//    override void render() {
//        this.entities.sort!((a,b) => dot(camera.pos - a.pos, camera.rot.column[2]) > dot(camera.pos - b.pos, camera.rot.column[2]));
//        this.entities.each!(e => e.render());
//    }
//
//    override void add(Entity e) {
//        this.entities.insert(e);
//        e.connect({this.entities.linearRemoveElement(e);});
//    }
//}
