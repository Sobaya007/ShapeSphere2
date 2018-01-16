module sbylib.entity.Entity;

public {
    import sbylib.collision.CollisionEntry;
    import sbylib.mesh.Mesh;
    import sbylib.mesh.Object3D;
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

    this(){
        this._obj = new Object3D(this);
        this.visible = true;
    }

    this(Geometry geom, Material mat) {
        this();
        this.setMesh(new Mesh(geom, mat, this));
    }

    this(CollisionGeometry colGeom) {
        this();
        this.colEntry = Just(new CollisionEntry(colGeom, this));
    }

    this(Geometry geom, Material mat, CollisionGeometry colGeom) {
        this();
        this.setMesh(new Mesh(geom, mat, this));
        this.colEntry = Just(new CollisionEntry(colGeom, this));
    }

    CollisionEntry getCollisionEntry() {
        return this.colEntry.get();
    }

    Mesh getMesh() {
        return this.mesh.get();
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
        assert(this.parent is null);
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

    void createCollisionPolygon() {
        this.mesh.geom.apply!(g => addChild(new Entity(g.createCollisionPolygons())));
        foreach(child; this.children) {
            child.createCollisionPolygon();
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
        if (this.colEntry.isJust) {
            this.getCollisionEntry().collide(result, colEntry);
        }
        foreach (child; this.children) {
            child.collide(result, colEntry);
        }
    }

    CollisionInfoRay[] collide(CollisionRay ray) {
        CollisionInfoRay[] result;
        if (this.getCollisionEntry()) {
            auto info = this.getCollisionEntry.collide(ray);
            if (info.isJust) {
                result ~= info.get;
            }
        }
        foreach (child; this.children) {
            result ~=  child.collide(ray);
        }
        return result;
    }

    Maybe!CollisionInfoRay rayCast(CollisionRay ray) {
        auto infos = this.collide(ray);
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

class EntityTemp(Geom, Mat) : Entity {
    alias M = MeshTemp!(Geom, Mat);
    private M mesh;

    this(Geom g) {
        super();
        this.mesh = new M(g, this);
        super.setMesh(this.mesh);
    }

    this(Geom g, Mat m) {
        super();
        this.mesh = new M(g, m, this);
        super.setMesh(this.mesh);
    }

    this(Geom g, CollisionGeometry colGeom) {
        super(colGeom);
        this.mesh = new M(g, this);
        super.setMesh(this.mesh);
    }

    this(Geom g, Mat m, CollisionGeometry colGeom) {
        super(colGeom);
        this.mesh = new M(g, m, this);
        super.setMesh(this.mesh);
    }

    override M getMesh() {
        return this.mesh;
    }

//    override void setMesh(Geometry geom, Material mat) {
//        assert(cast(Geom)geom);
//        assert(cast(Mat)mat);
//        this.mesh = new M(cast(Geom)geom, cast(Mat)mat, this);
//        super.setMesh(mesh);
//    }

    alias obj this;
}
