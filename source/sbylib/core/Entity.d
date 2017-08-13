module sbylib.core.Entity;

public {
    import sbylib.collision.CollisionEntry;
    import sbylib.mesh.Mesh;
    import sbylib.mesh.Object3D;
    import sbylib.utils.Array;
}

class Entity {
    private Mesh mesh;
    private CollisionEntry colEntry;
    private World world;
    private Entity parent;
    private Entity[] children;
    private Object3D _obj;
    private void* userData;

    this(){
        this._obj = new Object3D(this);
    }

    this(Geometry geom, Material mat) {
        this();
        this.setMesh(new Mesh(geom, mat, this));
    }

    this(CollisionGeometry colGeom) {
        this();
        this.colEntry = new CollisionEntry(colGeom, this);
    }

    this(Geometry geom, Material mat, CollisionGeometry colGeom) {
        this();
        this.setMesh(new Mesh(geom, mat, this));
        this.colEntry = new CollisionEntry(colGeom, this);
    }

    CollisionEntry getCollisionEntry() {
        return this.colEntry;
    }

    Mesh getMesh() {
        return this.mesh;
    }

    inout(Object3D) obj() @property inout {
        return this._obj;
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

    void* getUserData() {
        return this.userData;
    }

    void setUserData(void* userData) in {
        assert(this.parent is null);
    } body {
        this.userData = userData;
    }

    void clearChildren() {
        foreach (child; this.children) {
            child.parent = null;
        }
        this.children = null;
    }

    void addChild(Entity entity) {
        this.children ~= entity;
        entity.setParent(this);
        if (this.world is null) return;
        entity.setWorld(world);
    }

    void createCollisionPolygon() in {
        assert(this.getMesh() !is null);
    } body {
        foreach (polygon; this.getMesh().geom.createCollisionPolygons()) {
            auto entity = new Entity(polygon);
            this.addChild(entity);
        }
    }

    void render() in {
        assert(this.world);
    } body {
        if (this.mesh) {
            this.mesh.render();
        }
        foreach (child; this.children) {
            child.render();
        }
    }

    void collide(ref Array!CollisionInfo result, Entity entity) {
        entity.collide(result, this.getCollisionEntry());
        foreach (child; this.children) {
            child.collide(result, entity);
        }
    }

    void collide(ref Array!CollisionInfo result, CollisionEntry colEntry) {
        if (colEntry is null) return;
        if (this.getCollisionEntry()) {
            result ~= this.getCollisionEntry().collide(colEntry);
        }
        foreach (child; this.children) {
            child.collide(result, colEntry);
        }
    }

    CollisionInfoRay[] collide(CollisionRay ray) {
        CollisionInfoRay[] result;
        if (this.getCollisionEntry()) {
            result ~= this.getCollisionEntry.collide(ray);
        }
        foreach (child; this.children) {
            result ~=  child.collide(ray);
        }
        return result;
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

    private void onSetWorld(World world) {
        if (this.mesh) {
            this.mesh.onSetWorld(world);
        }
    }

    private void setParent(Entity entity) in {
        assert(this.userData is null);
    } body {
        this.parent = entity;
        this._obj.onSetParent(entity);
    }

    private void setMesh(Mesh mesh) in {
        assert(mesh.getOwner() == this);
    } body {
        this.mesh = mesh;
        if (this.world is null) return;
        this.mesh.onSetWorld(this.world);
    }

    private void setCollisionEntry(CollisionEntry colEntry) in {
        assert(colEntry.getOwner() == this);
    } body {
        this.colEntry = colEntry;
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
