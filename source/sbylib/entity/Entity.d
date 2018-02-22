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

/*
   ルール一覧

   1. Entity同士は親子関係を為す

   - 親子関係が確立する直前、子は親を持たない必要がある
   - 親子関係が確立する直前、親はその子をまだ持っていない必要がある


   2. EntityはWorldとの接続を持つ

   - WorldがEntityを持っている⇔ EntityはWorldを持っている
   - WorldがEntityに接続される直前、EntityはWorldと未接続でなければならない
   - WorldとEntityの接続が断たれるとき、EntityはWorldに接続されていなければならない

   3. Worldと親子

   - EntityがWorldとの接続を持っているとき、その親と全ての子はそのWorldとの接続を持っている

   4. データの解放

   - Entityはどこかで解放(destroy)される必要がある
   - Entityが解放する直前、Worldと未接続である必要がある
 */

class Entity {

    import sbylib.utils.Functions;

    mixin buildReadonly!(Maybe!Mesh, "mesh");
    mixin buildReadonly!(Object3D, "obj");
    mixin buildReadonly!(Maybe!World, "world");
    string name;
    Maybe!CollisionEntry colEntry;
    private Maybe!Entity parent;
    private Entity[] children;
    private Maybe!Variant userData;
    bool visible; // Materialに書くと、Materialが同じでVisiblityが違う物体が実現できない
    void delegate()[] onAdd;

    /*
       Create/Destroy
     */
    this(string file = __FILE__, int line = __LINE__){
        this._obj = new Object3D(this);
        import std.conv;
        this.name = file ~ " : " ~ line.to!string;
        this.visible = true;
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

    void destroy() in {
        // Entityが解放する直前、Worldと未接続である必要がある
        assert(this.world.isNone);
    } body {
        this.mesh.destroy();
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

    /*
       親子関係の確立

        事前条件:
            - childはthisと未接続
            - childはWorldと未接続

        事後条件:
            - thisとchildは接続
            - thisがWorldと接続⇔ childはWorldと接続

        備考:
            - obj同士の親子関係も確立される
    */
    void addChild(Entity child) in {
        import std.array;
        assert(child.isParentConnected == false);
        assert(child.isWorldConnected == false);
    } out {
        import std.array;
        assert(child.isParentConnected == true);
        assert(this.isWorldConnected == child.isWorldConnected);
    } body {

        // Worldとの接続
        if (this.world.isJust) {
            this.world.add(child);
        }

        // 親子の接続
        child.parent = Just(this);
        this.children ~= child;
        child.obj.onSetParent(this);

    }

    /*
       親子関係及びWorldとの接続の解消

        事後条件:
            - thisはWorldと未接続
            - thisに親がいた場合、親との関係は解消されている

        備考:
            - this以下の親子関係は維持される
    */
    void remove() out {
        assert(this.isWorldConnected == false);
        assert(this.isParentConnected == false);
    } body {

        // 親子の接続解消
        this.parent.apply!(parent => parent.children.remove!(child => child is this));
        this.parent = None!Entity;

        // Worldとの接続解消
        if (this.world.isJust) {
            this.world.remove(this);
        }
    }

    /*
       全ての子のremove

        事後条件:
            - childrenは全てWorldと未接続
            - childrenとthisとの親子関係はすべて解消されている

        備考:
            - chlidren以下の親子関係は維持される
    */
    void clearChildren() out {
        import std.algorithm;
        assert(children.all!(child => child.isWorldConnected == false));
        assert(children.all!(child => child.isParentConnected == false));
    } body {

        /*
           Worldとの接続解消を先にやると、「Entityの木の中でWorldとの接続状況は統一されていなければならない」というルールに反する(thisはWorldに接続されているが、childrenは接続されていないという状況になり得る)
           したがって、先に木を分けてからWorldと接続解消する必要がある
        */

        // 親子の接続解消
        this.children.each!(child => child.parent = None!Entity);

        // Worldとの接続解消
        if (this.world.isJust) {
            this.children.each!(child => this.world.remove(child));
        }

        this.children.length = 0;
    }

    void setWorld(World world) {
        this._world = Just(world);
        this.mesh.setWorld(world);
        this.onAdd.each!(f => f());
    }

    void unsetWorld() {
        this._world = None!World;
    }

    Maybe!Entity getParent() {
        return this.parent;
    }

    Entity getRootParent() out (res) {
        assert(res !is null);
    } body {
        return this.parent.getRootParent().getOrElse(this);
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

    /*
       thisがWorldと接続されているかを返す

       備考:
            WorldとEntityが接続されている⇔ WorldがEntityを持っている && EntityがWorldを持っている
            だが、片方だけが持っているような状態を仮定しないので、片側のみの確認で良い
     */
    private bool isWorldConnected() out (connected) {
        this.getRootParent().traverse((Entity e) {
            assert(e.world.isJust == connected);
        });
    } body {
        return this.world.isJust;
    }

    /*
       thisがParentと接続されているかを返す

       備考:
            Parentとthisが接続されている⇔ Parentがthisを持っている && thisがParentを持っている
            だが、片方だけが持っているような状態を仮定しないので、片側のみの確認で良い
     */
    bool isParentConnected() {
        return this.parent.isJust;
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
