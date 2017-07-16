module sbylib.core.Entity;

public {
    import sbylib.collision.CollisionEntry;
    import sbylib.mesh.Mesh;
    import sbylib.mesh.Object3D;
}

class Entity {
    private Mesh mesh;
    private CollisionEntry colEntry;
    private Bahamut world;
    private Entity parent;
    private Entity[] children;
    Object3D obj;
    void* userData;

    this(){
        this.obj = new Object3D();
    }

    this(Mesh mesh) {
        this.setMesh(mesh);
        this();
    }

    this(CollisionEntry colEntry) {
        this.setCollisionEntry(colEntry);
        this();
    }

    this(Mesh mesh, CollisionEntry colEntry) {
        this.setMesh(mesh);
        this.setCollisionEntry(colEntry);
        this();
    }

    void setMesh(Mesh mesh) {
        this.mesh = mesh;
        if (this.world is null) return;
        this.mesh.onSetWorld(this.world);
    }

    void setCollisionEntry(CollisionEntry colEntry) {
        this.colEntry = colEntry;
    }

    CollisionEntry getCollisionEntry() {
        return this.colEntry;
    }

    Mesh getMesh() {
        return this.mesh;
    }

    void setWorld(Bahamut world) {
        this.world = world;
        if (this.mesh is null) return;
        this.onSetWorld(world);
    }

    void clearChildren() {
        foreach (child; this.children) {
            child.parent = null;
        }
        this.children = null;
    }

    void addChild(Entity entity) {
        this.children ~= entity;
        entity.parent = this;
        if (this.world is null) return;
        entity.onSetWorld(world);
    }

    void createCollisionPolygon() in {
        assert(this.mesh !is null);
    } body {
        foreach (polygon; this.mesh.geom.createCollisionPolygons()) {
            auto entity = new Entity;
            entity.setCollisionEntry(polygon);
            this.addChild(entity);
        }
    }

    private void onSetWorld(Bahamut world) {
        this.mesh.onSetWorld(world);
    }
}

class EntityTemp(Geom, Mat) : Entity {
    alias M = MeshTemp!(Geom, Mat);
    private M mesh;

    this(M mesh) {
        this.mesh = mesh;
        this.setMesh(mesh);
    }

    this(Geom g) {
        this.mesh = new M(g);
        this.setMesh(this.mesh);
    }

    this(Geom g, Mat m) {
        this.mesh = new M(g, m);
        this.setMesh(this.mesh);
    }

    override M getMesh() {
        return this.mesh;
    }

    override void setMesh(Mesh mesh) {
        assert(mesh is null || cast(M)mesh !is null);
        this.mesh = cast(M)mesh;
        super.setMesh(mesh);
    }

    alias getMesh this;
}
