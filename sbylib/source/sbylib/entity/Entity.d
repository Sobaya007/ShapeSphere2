module sbylib.entity.Entity;

public {
    import sbylib.collision.CollisionEntry;
    import sbylib.core.Process;
    import sbylib.entity.Mesh;
    import sbylib.entity.Object3D;
    import sbylib.utils.Array;
    import sbylib.utils.Maybe;
    import std.variant;
}
import std.traits;
import std.meta;

/*
   ルール一覧

   1. Entity同士は親子関係を為す

   - 親子関係が確立する直前、子は親を持たない必要がある
   - 親子関係が確立する直前、親はその子をまだ持っていない必要がある


   2. EntityはWorldとの接続を持つ

   - WorldがEntityを持っている⇔ EntityはWorldを持っている
   - WorldがEntityに接続される直前、EntityはWorldと未接続でなければならない
   - WorldとEntityの接続が断たれるとき、EntityはWorldに接続されていなければならない
   - EntityがWorldとの接続を持っているとき、その親と全ての子はそのWorldとの接続を持っている


   3. データの解放

   - Entityはどこかで解放(destroy)される必要がある
   - Entityが解放する直前、Worldと未接続である必要がある
 */

alias ID = int;

class Entity {

    import sbylib.utils.Functions;

    mixin buildReadonly!(Maybe!Mesh, "mesh");
    mixin buildReadonly!(Maybe!World, "world");

    @Proxied Object3D obj;
    string name;
    Maybe!CollisionEntry colEntry;
    private Maybe!Entity parent;
    private Entity[] children;
    private Variant[string] userData;
    bool visible; // Materialに書くと、Materialが同じでVisiblityが違う物体が実現できない
    void delegate()[] onAdd;
    void delegate()[] onPreRender;
    void delegate()[] onPostRender;

    private Process[] processes;

    mixin Proxy;

    /*
       Create/Destroy
     */
    this(string file = __FILE__, int line = __LINE__){
        this.obj = new Object3D(this);
        import std.conv;
        this.name = file ~ " : " ~ line.to!string;
        this.visible = true;
    }

    this(Geometry geom, Material mat, string file = __FILE__, int line = __LINE__) {
        this(new Mesh(geom, mat, this), file, line);
    }

    this(Mesh mesh, string file = __FILE__, int line = __LINE__) {
        this(file, line);
        setMesh(mesh);
    }

    this(CollisionGeometry colGeom, string file = __FILE__, int line = __LINE__) {
        this(file, line);
        this.colEntry = Just(new CollisionEntry(colGeom, this));
    }

    this(Geometry geom, Material mat, CollisionGeometry colGeom, string file = __FILE__, int line = __LINE__) {
        this(new Mesh(geom, mat, this), file, line);
        this.colEntry = Just(new CollisionEntry(colGeom, this));
    }

    /*
       Entityの破壊

       事前条件:
            - Worldと未接続

       備考:
            デストラクタでやらないのは、他スレッドでGCが起動してデストラクタが起動した場合にOpenGLの命令を呼べなくなるから
     */
    void destroy()
        in(this.isWorldConnected == false, "Calling 'destroy' must be after 'remove'")
    {
        this.mesh.destroy();
        foreach (p; this.processes) p.kill();
    }

    /*
       User Data access
     */

    Maybe!T getUserData(T)(string key) {
        return this.userData.at(key).fmapAnd!((Variant v) => wrapPointer(v.peek!T));
    }

    void setUserData(T)(string key, T userData) {
        this.userData[key] = Variant(userData);
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
    void addChild(Entity child)
        in(child.isParentConnected == false, "addChild's argument must not have parent.")
        in(child.isWorldConnected == false, "addChild's argument must not be added to World.")
        out(;child.isParentConnected == true)
        out(;this.isWorldConnected == child.isWorldConnected)
    {

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
    void remove()
        out(;this.isWorldConnected == false)
        out(;this.isParentConnected == false)
    {

        // 親子の接続解消
        import std.algorithm : aremove = remove;
        this.parent.apply!((parent) {
            parent.children = parent.children.aremove!(child => child is this);
        });
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
    void clearChildren()
    out {
        import std.algorithm : all;
        assert(children.all!(child => child.isWorldConnected == false));
        assert(children.all!(child => child.isParentConnected == false));
    }
    do {
        import std.algorithm : each;

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

    package(sbylib) void setWorld(World world)
        in(this.world.isNone)
    {
        import std.algorithm : each;

        this._world = Just(world);
        this.mesh.setWorld(world);
        this.onAdd.each!(f => f());
    }

    package(sbylib) void unsetWorld() {
        this._world = None!World;
    }

    package(sbylib) void setMesh(Mesh m)
        in(m.owner == this)
        in(this.world.isNone)
    {
        this._mesh = Just(m);
    }

    Entity[] getChildren() {
        return children;
    }

    Maybe!Entity getParent() {
        return this.parent;
    }

    Entity getRootParent()
        out(res; res !is null)
    {
        return this.parent.getRootParent().getOrElse(this);
    }

    debug int getDescendantNum() {
        import std.algorithm : map, sum, max;

        return children.map!(child => max(1, child.getDescendantNum)).sum;
    }

    Maybe!ID getID() {
        return mesh.mat.getID();
    }

    void render()
        in(this.world.isJust)
    {
        import std.algorithm : each;

        if (!this.visible) return;
        onPreRender.each!(f => f());
        this.mesh.render();
        onPostRender.each!(f => f());
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

    Maybe!Entity getNext() {
        import std.algorithm;
        import std.array;
        if (this.children.empty) {
            return this.parent.fmap!((Entity parent) {
                auto brothers = parent.getChildren();
                auto idx = brothers.countUntil(this);
                return brothers[idx];
            });
        } else {
            return Just(this.children.front);
        }
    }

    auto toRange() {
        import std.range;
        struct Iterator {
            private Maybe!Entity e;

            bool empty() {
                return e.isJust;
            }

            Entity front() {
                return e.unwrap();
            }
            
            void popFront() {
                e = front.getNext();
            }
        }
        static assert(isInputRange!(Iterator));
        return Iterator(Just(this));
    }

    void buildBVH() {
        this.traverse((Entity e) {
            auto polygons = e.mesh.geom.createCollisionPolygon();
            import std.array;
            e.colEntry = polygons.fmapAnd!((CollisionGeometry[] p) => p.empty ? None!CollisionEntry : Just(new CollisionEntry(new CollisionBVH(p), e)));
        });
    }

    void buildSphere() {
        this.traverse((Entity e) {
            auto capsule = e.mesh.geom.createCollisionSphere();
            e.colEntry = capsule.fmap!((CollisionGeometry g) => new CollisionEntry(g, e));
            debug {
                import sbylib.core.Core;
                import sbylib.material.WireframeMaterial;
                import sbylib.entity.Entity;
                import sbylib.math.Vector;
                import sbylib.utils.Maybe;
                Core().addProcess((Process proc) {
                    capsule.apply!((capsule) {

                        auto geom = capsule.createGeometry();
                        auto mat = new WireframeMaterial(vec4(1));
                        //auto debugEntity = new Entity(geom, mat);
                        //debugEntity.name = "Debug Wire Capsule";
                        //e.addChild(debugEntity);
                    });
                    proc.kill();
                }, "build capsule");
            }
        });
    }

    void buildCapsule() {
        this.traverse((Entity e) {
            auto capsule = e.mesh.geom.createCollisionCapsule();
            e.colEntry = capsule.fmap!((CollisionGeometry g) => new CollisionEntry(g, e));
            debug {
                import sbylib.core.Core;
                import sbylib.material.WireframeMaterial;
                import sbylib.entity.Entity;
                import sbylib.math.Vector;
                import sbylib.utils.Maybe;
                Core().addProcess((Process proc) {
                    capsule.apply!((capsule) {
                        auto geom = capsule.createGeometry();
                        auto mat = new WireframeMaterial(vec4(1));
                        auto debugEntity = new Entity(geom, mat);
                        debugEntity.name = "Debug Wire Capsule";
                        e.addChild(debugEntity);
                    });
                    proc.kill();
                }, "build capsule");
            }
        });
    }

    void collide(ref Array!CollisionInfo result, Entity entity) {
        if (this.colEntry.isJust) {
            entity.collide(result, this.colEntry.unwrap);
        }
        foreach (child; this.children) {
            child.collide(result, entity);
        }
    }

    void collide(ref Array!CollisionInfo result, CollisionEntry colEntry)
        in(colEntry !is null)
    {
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
    private bool isWorldConnected()
    out (connected) {
        this.getRootParent().traverse((Entity e) {
            assert(e.world.isJust == connected);
        });
    }
    do {
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

    void addProcess(void delegate() func) {
        import sbylib.core.Core;
        Process proc;
        proc = Core().addProcess({func(); proc.name = this.name;}, this.name);
        processes ~= proc;
    }

    override string toString() {
        return toString(true);
    }

    string toString(bool recursive) {
        import std.format;
        return toString((Entity e) => format!"name      : %s\nMesh      : %s\nCollision : %s\nChildren  : %d"(e.name, e.mesh.toString(), e.colEntry.toString(), e.children.length), recursive);
    }

    string toString(string function(Entity) func, bool recursive) {
        import std.format, std.range;
        import std.algorithm : map;
        import sbylib.utils.Functions;
        auto result = func(this);
        if (recursive && children.length > 0) {
            result ~= this.children.map!(child => child.toString(func, recursive)).join("\n").indent(3);
        }
        return result;
    }
}

/*
template VisitDataAcceptable(choices...) {
    enum VisitDataAcceptable =
        allSatisfy!(isCallable, choices)
        && allSatisfy!(hasOnlyOneInput, choices[0..$-1])
        && Parameters!(choices[$-1]).length <= 1;
}

enum hasOnlyOneInput(alias func) = Parameters!(func).length == 1;

void visitUserData(choices...)(Entity e) if (VisitDataAcceptable!(choices)) {

    static foreach (choice; choices) {{
        static if (Parameters!(choice).length){
            auto userData = e.getUserData!(Parameters!(choice)[0]);
            if (userData.isJust) {
                choice(userData.get());
                return;
            }
        }
    }}
    static if (Parameters!(choices[$-1]).length == 0) {
        choices[$-1]();
    }
}

*/
