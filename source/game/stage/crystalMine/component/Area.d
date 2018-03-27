module game.stage.crystalMine.component.Area;

struct Area {

    import std.json;
    import sbylib;
    import std.range : iota;
    import std.algorithm : map, each;
    import std.array : array;
    import game.stage.crystalMine.component;
    import game.stage.crystalMine.StageMaterial;
    import game.Game;

    private size_t index;
    private JSONValue[] parent;

    struct Inst {
        Entity entity;
        Entity mapEntity;
        Entity characterEntity;
        Entity moveEntity;
        Entity crystalEntity;
        Entity lightEntity;
        Entity switchEntity;
        Entity otherEntity;
    }

    private static Inst[] insts;

    alias inst this;

    this(size_t index, JSONValue[] parent) {
        this.index = index;
        this.parent = parent;

        // 悲しみの初期化処理
        characters.each!(x => x.character());
        moves.each!(x => x.shape());
        crystals.each!(x => x.light());
        lights.each!(x => x.light());
        switches.each!(x => x.entity());
    }

    void create() {
        auto entity = new Entity;
        auto mapEntity = new Entity;
        auto characterEntity = new Entity;
        auto moveEntity = new Entity;
        auto crystalEntity = new Entity;
        auto lightEntity = new Entity;
        auto switchEntity = new Entity;
        auto otherEntity = new Entity;

        entity.addChild(mapEntity);
        entity.addChild(characterEntity);
        entity.addChild(moveEntity);
        entity.addChild(lightEntity);
        entity.addChild(otherEntity);
        otherEntity.addChild(crystalEntity);
        otherEntity.addChild(switchEntity);

        insts[index] = Inst(entity, mapEntity, characterEntity, moveEntity, crystalEntity, lightEntity, switchEntity, otherEntity);

        entity.name = name;
        crystalEntity.name = "crystal";
        mapEntity.name = "map";
        characterEntity.name = "character";
        moveEntity.name = "move";
        lightEntity.name = "light";
        switchEntity.name = "switch";
        otherEntity.name = "other";
    }

    auto inst() {
        if (insts.length <= index) insts.length = index+1;
        if (insts[index] == Inst.init) create();
        return insts[index];
    }

    auto obj() {
        return parent[index].object();
    }

    string name() {
        return obj["name"].str();
    }

    void name(string n) {
        obj["name"] = n;
    }

    auto debugPos() {
        return vec3(obj["debugPos"].as!(float[]));
    }

    auto debugPos(vec3 c) {
        foreach (i; 0..3) {
            obj["debugPos"].array[i] = c[i];
        }
    }

    auto lights() {
        auto root = obj["Lights"].array();
        return root.length.iota.map!(i => Light(i, root, this.lightEntity));
    }

    auto moves() {
        auto root = obj["Moves"].array();
        return root.length.iota.map!(i => Move(i, root, this.moveEntity));
    }

    auto crystals() {
        auto root = obj["Crystals"].array();
        return root.length.iota.map!(i => Crystal(i, root, this.crystalEntity));
    }

    auto characters() {
        auto root = obj["NPC"].array();
        return root.length.iota.map!(i => Character(i, root, this.characterEntity));
    }

    auto switches() {
        auto root = obj["Switches"].array();
        return root.length.iota.map!(i => Switch(i, root, this.switchEntity));
    }

    auto paths() {
        return obj["Models"].array.map!(m => m.str);
    }

    void load() {
        import std.concurrency, std.stdio;
        import core.thread;
        spawn(function (immutable(string[]) paths) {
            try {
                auto loader = new XLoader();
                foreach (path; paths) {
                    writeln("Model Load Start. ModelPath is ", path);
                    auto loaded = loader.load(ModelPath(path));
                    writeln("Model was Loaded.");
                    ownerTid.send(loaded);
                    Thread.sleep(1000.msecs);
                }
            } catch (Error e) {
                writeln(e);
                import core.stdc.stdlib;
                exit(1);
            }
        }, paths.array.idup);
    }

    void step() {
        import std.concurrency, std.datetime;
        receiveTimeout(0.msecs, &onReceive);

        debug Game.startTimer("character.step()");
        this.characters.each!(c => c.step);
        debug Game.stopTimer("character.step()");

        debug Game.startTimer("player.step()");
        Game.getPlayer().step();
        debug Game.stopTimer("player.step()");
    }

    void onReceive(immutable XEntity entity) {
        import std.stdio;
        writeln("received");
        auto m = entity.buildEntity(StageMaterialBuilder());
        this.mapEntity.addChild(m);
        m.buildBVH();
        m.traverse!((Entity e) {
            auto name = e.mesh.mat.wrapCast!(StageMaterial).name;
            if (name.isNone) return;
            e.setUserData(name.get);
        });
        writeln("BVH construction was finished.");
    }

    void addCrystal(ref JSONValue area, vec3 pos) {
        auto obj = parseJSON("{}");
        obj["pos"] = JSONValue(pos.array[]);
        obj["color"] = JSONValue(vec3(1).array[]);
        area["Crystals"].array ~= obj;
        crystals.each!(x => x.light());
    }

    void addLight(ref JSONValue area, vec3 pos) {
        auto obj = parseJSON("{}");
        obj["pos"] = JSONValue(pos.array[]);
        obj["color"] = JSONValue(vec3(1).array[]);
        area["Lights"].array ~= obj;
        lights.each!(x => x.light());
    }
}
