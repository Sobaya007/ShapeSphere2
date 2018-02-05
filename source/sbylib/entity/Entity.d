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
    private Maybe!Mesh mesh;
    private Maybe!CollisionEntry colEntry;
    private World world;
    private Entity parent;
    private Entity[] children;
    private Object3D _obj;
    private Maybe!Variant userData;
    private string name;
    bool visible;

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
        this.mesh.destroy();
        foreach (child; this.children) {
            child.destroy();
        }
    }

    Maybe!Mesh getMesh() {
        return this.mesh;
    }

    inout(Object3D) obj() @property inout {
        return this._obj;
    }

    World getWorld() {
        return this.world;
    }

    string getName() {
        return this.name;
    }

    void setName(string name) {
        this.name = name;
    }

    void setWorld(World world) in {
        assert(world);
    } body {
        this.world = world;
        this.onSetWorld(world);
        foreach (child; this.children) {
            child.setWorld(world);
        }
    }

    Maybe!Variant getUserData() {
        return this.userData;
    }

    void setUserData(T)(T userData) in {
        //assert(this.parent is null);
    } body {
        this.userData = wrap(Variant(userData));
    }

    void clearChildren() {
        foreach (child; this.children) {
            child.parent = null;
        }
        this.children = null;
    }

    void addChild(Entity entity) in {
        assert(entity !is null);
    } body {
        this.children ~= entity;
        entity.setParent(this);
        if (this.world is null) return;
        entity.setWorld(world);
    }

    Entity[] getChilren() {
        return this.children;
    }

    void buildBVH() {
        buildBVH((bvh) {});
    }

    void buildBVH(void delegate(Entity) func) {
        this.mesh.apply!((m) {
            auto polygons = m.geom.createCollisionPolygon();
            if (polygons.length == 0) return;
            auto bvh = new Entity(new CollisionBVH(polygons));
            addChild(bvh);
            func(bvh);
        });

        foreach(child; this.children) {
            child.buildBVH(func);
        }
    }

    /*
    void collect(bool function(Mesh) cond)(ref Array!Entity result) {
        if (this.mesh && cond(this.mesh)) {
            result ~= this;
        }
        foreach (child; this.children) {
            child.collect!(cond)(result);
        }
    }
    */

    void collect(bool function(Mesh) cond)(ref Array!Entity trueResult, ref Array!Entity falseResult) {
        if (this.mesh.isJust) {
            if (cond(this.mesh.get)) {
                trueResult ~= this;
            } else {
                falseResult ~= this;
            }
        }
        foreach (child; this.children) {
            child.collect!(cond)(trueResult, falseResult);
        }
    }

    void render() in {
        assert(this.world);
    } body {
        if (!this.visible) return;
        this.mesh.render();
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

    Entity getParent() {
        return this.parent;
    }

    Entity getRootParent() {
        if (this.parent is null) return this;
        return this.parent.getRootParent();
    }

    uint getChildNum() {
        uint res = 0;
        if (this.parent !is null) res++;
        foreach (child; this.children) {
            res += child.getChildNum();
        }
        return res;
    }

    Entity[] getChildren() {
        return this.children;
    }

    void remove() {
        this.world.remove(this);
    }

    private void onSetWorld(World world) {
        this.mesh.onSetWorld(world);
    }

    private void setParent(Entity entity) {
        this.parent = entity;
        this._obj.onSetParent(entity);
    }

    private void setMesh(Mesh mesh) in {
        assert(mesh.getOwner() == this);
    } body {
        this.mesh = Just(mesh);
        if (this.world is null) return;
        this.mesh.onSetWorld(this.world);
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
