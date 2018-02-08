module sbylib.entity.Entity;

public {
    import sbylib.collision.CollisionEntry;
    import sbylib.entity.Mesh;
    import sbylib.entity.Object3D;
    import sbylib.utils.Array;
    import sbylib.utils.Maybe;
    import std.variant;
}
import std.algorithm;

class Entity {

    import sbylib.utils.Functions;

    mixin buildReadonly!(Maybe!Mesh, "mesh");
    mixin buildReadonly!(Object3D, "obj");
    mixin buildReadonly!(Maybe!World, "world");
    string name;
    private Maybe!CollisionEntry colEntry;
    private Maybe!Entity parent;
    private Entity[] children;
    private Maybe!Variant userData;
    bool visible;


    /*
       Create/Destroy
     */
    this(string file = __FILE__, int line = __LINE__){
        this._obj = new Object3D(this);
        this.visible = true;
        import std.conv;
        this.name = file ~ " : " ~ line.to!string;
    }

    this(Geometry geom, Material mat, string file = __FILE__, int line = __LINE__) {
        this(file, line);
        this.setMesh(new Mesh(geom, mat, this));
    }

    this(CollisionGeometry colGeom, string file = __FILE__, int line = __LINE__) {
        this(file, line);
        this.colEntry = Just(new CollisionEntry(colGeom, this));
    }

    this(Geometry geom, Material mat, CollisionGeometry colGeom, string file = __FILE__, int line = __LINE__) {
        this(file, line);
        this.setMesh(new Mesh(geom, mat, this));
        this.colEntry = Just(new CollisionEntry(colGeom, this));
    }

    void destroy() {
        this.traverse!((Entity e) => e.mesh.destroy);
    }


    /*
       User Data access
     */

    Maybe!T getUserData(T)() {
        return this.userData.fmapAnd!((Variant v) => wrapPointer(v.peek!T));
    }

    Maybe!string getUserDataType() {
        return this.userData.fmap!((Variant v) => v.type.stringof);
    }

    void setUserData(T)(T userData) {
        this.userData = wrap(Variant(userData));
    }


    /*
       Parent/Child Access
     */

    void addChild(Entity entity) {
        entity.parent = Just(this);
        entity.obj.onSetParent(this);
        this.children ~= entity;
        this.world.add(entity);
    }

    void clearChildren() out {
        assert(this.children.length == 0);
    } body {
        this.children.each!(child => child.remove());
        this.children.each!(child => child.parent = None!Entity);
        this.children = null;
    }

    Maybe!Entity getParent() {
        return this.parent;
    }

    Entity getRootParent() {
        return this.parent.getRootParent().getOrElse(this);
    }

    Entity[] getChildren() {
        return this.children;
    }

    invariant {
        assert(this.children.all!(child => child.parent.isJust));
        assert(this.children.all!(child => child.parent.get() == this));
    }

    /*
       World Access
     */

    void remove() {
        this.world.remove(this);
        this._world = None!World;
    }

    void setWorld(Maybe!World world) {
        this.traverse((Entity e) {
            e._world = world;
            e.mesh.onSetWorld(world);
        });
    }

    void render() in {
        assert(this.world.isJust, this.toString());
    } body {
        if (!this.visible) return;
        this.mesh.render();
    }


    void traverse(alias func)() {
        func(this);
        foreach (child; this.children) {
            child.traverse!(func);
        }
    }

    void traverse(void delegate(Entity) func) {
        func(this);
        foreach (child; this.children) {
            child.traverse(func);
        }
    }

    void buildBVH() {
        this.traverse((Entity e) {
            auto polygons = e.mesh.geom.createCollisionPolygon();
            e.colEntry = polygons.fmap!((CollisionGeometry[] p) => new CollisionEntry(new CollisionBVH(p), e));
        });
    }

    void collide(ref Array!CollisionInfo result, Entity entity) {
        if (this.colEntry.isJust) {
            entity.collide(result, this.colEntry.get);
        }
        foreach (child; this.children) {
            child.collide(result, entity);
        }
    }

    void collide(ref Array!CollisionInfo result, CollisionEntry colEntry) in {
        assert(colEntry !is null);
    } body {
        this.colEntry.collide(result, colEntry);
        foreach (child; this.children) {
            child.collide(result, colEntry);
        }
    }

    void collide(ref Array!CollisionInfoRay result, CollisionRay ray) {
        this.colEntry.collide(result, ray);
        foreach (child; this.children) {
            child.collide(result, ray);
        }
    }

    Maybe!CollisionInfoRay rayCast(CollisionRay ray) {
        auto infos = Array!CollisionInfoRay(0);
        scope (exit) infos.destroy();
        this.collide(infos, ray);
        if (infos.length == 0) return None!CollisionInfoRay;
        import std.algorithm;
        import sbylib.math.Vector;
        import std.stdio;
        return Just(infos.minElement!(info => lengthSq(info.point - ray.start)));
    }

    private void setMesh(Mesh m) in {
        assert(m.getOwner() == this);
        assert(this.world.isNone);
    } body {
        this._mesh = Just(m);
    }

    override string toString() {
        import std.format, std.range;
        import sbylib.utils.Functions;
        auto result = format!"name       : %s\nMesh       : %s\nCollision : %s\nData      : %s\n"(name, this.mesh.toString(), this.colEntry.toString(), this.userData.toString);
        if (children.length > 0) {
            result ~= format!"Children(%d):\n%s"(this.children.length, this.children.map!(child => child.toString()).join("\n").indent(3));
        }
        return result;
    }

    alias obj this;
}

class TypedEntity(G, M) {

    import sbylib.utils.Functions;

    mixin Proxy;

    @Proxied TypedMesh!(G, M) mesh;
    @Proxied Entity entity;

    alias entity this;
}

auto makeEntity(string file = __FILE__, int line = __LINE__) {
    return new Entity(file, line);
}

auto makeEntity(G, M)(G g, M m, string file = __FILE__, int line = __LINE__) {
    auto entity = new TypedEntity!(G, M);
    entity.entity = new Entity(file, line);
    entity.mesh = new TypedMesh!(G, M)(g, m, entity.entity);
    entity.entity.setMesh(entity.mesh);
    return entity;
}

auto makeEntity(CollisionGeometry colGeom, string file = __FILE__, int line = __LINE__) {
    return new Entity(colGeom, file, line);
}

auto makeEntity(G, M)(G g, M m, CollisionGeometry colGeom, string file = __FILE__, int line = __LINE__) {
    auto entity = new TypedEntity!(G, M);
    entity.entity = new Entity(colGeom, file, line);
    entity.mesh = new TypedMesh!(G, M)(g, m, entity.entity);
    entity.entity.setMesh(entity.mesh);
    return entity;
}
