module game.stage.crystalMine.CrystalMine;

import std.json, std.algorithm, std.array, std.file, std.range;

import sbylib;

import game.Game;
import game.stage.crystalMine.StageMaterial;
import game.stage.crystalMine.CrystalMaterial;
import game.stage.crystalMine.component;
import game.stage.Stage;
import std.concurrency, std.typecons;
import core.thread;

class CrystalMine : Stage {
    private Area area;

    private bool paused;

    private TypedEntity!(GeometryRect, ColorMaterial) fadeRect;

    private debug bool wireVisible = false;

    enum path = "Resource/stage/Stage1.json";

    private JSONValue root;

    private IViewport viewport;
    private Renderer renderer;

    this() {
        this.root = parseJSON(readText(path)).object();
        this.area = this.areas.find!(a => a.name == startArea).front;
        Game.getWorld3D().add(this.area.entity);
        this.area.load();

        Core().addProcess(&step, "Stage1");

        debug addDebugActions;

        this.fadeRect = makeColorEntity(vec4(0), 2,2);
        this.fadeRect.config.renderGroupName = "transparent";
        this.fadeRect.config.depthWrite = false;
        this.fadeRect.pos.z = 1;
        this.fadeRect.name = "Fade Rect";
        Game.getWorld2D().add(this.fadeRect);

        this.viewport = new AutomaticViewport(Core().getWindow);
        this.renderer = new Renderer;
    }

    auto obj() {
        return root.object();
    }

    string stageName() {
        return obj["StageName"].str();
    }

    string startArea() {
        return obj["StartArea"].str();
    }

    void startArea(string s) {
        obj["StartArea"] = s;
    }

    auto areas() {
        auto root = obj["Areas"].array;
        return root.length.iota.map!(i => Area(i, root));
    }

    void step() {
        if (!paused) {
            this.area.step();
        }
    }

    override void pause() {
        paused = true;
    }

    override void resume() {
        paused = false;
    }

    override Entity getStageEntity() {
        return this.area.stageEntity;
    }

    override Entity getCharacterEntity() {
        return this.area.characterEntity;
    }

    override Entity getMoveEntity() {
        return this.area.moveEntity;
    }

    override void render() {
        auto scene = Game.getScene();
        auto screen = Core().getWindow().getScreen();
        renderer.render(Game.getWorld3D(), screen, viewport, "regular");
        renderer.render(Game.getWorld3D(), screen, viewport, "transparent");
        screen.blitsTo(Game.getBackBuffer(), BufferBit.Color);
        renderer.render(Game.getWorld3D(), screen, viewport, "Crystal");
        screen.clear(ClearMode.Depth);
        renderer.render(Game.getWorld2D(), screen, viewport, "regular");
        renderer.render(Game.getWorld2D(), screen, viewport, "transparent");
    }

    override void transit(string name) {
        paused = true;
        AnimationManager().startAnimation(
            new Animation!vec4(color => this.fadeRect.color = color,
                setting(
                    vec4(0,0,0,0),
                    vec4(0,0,0,1),
                    60.frame,
                    &Ease.linear
                )
            )
        ).onFinish({
            assert(paused);
            paused = false;
            Game.getWorld3D().remove(this.area.entity);
            PointLightManager().clear();
            auto next = this.areas.find!(a => a.name == name).front;
            Game.getWorld3D().add(next.entity);
            Game.getPlayer().setCenter(vec3(0));
            next.load();
            this.area = next;
            AnimationManager().startAnimation(
                new Animation!vec4(color => this.fadeRect.color = color,
                    setting(
                        vec4(0,0,0,1),
                        vec4(0,0,0,0),
                        60.frame,
                        &Ease.linear
                    )
                )
            );
        });
    }

    void reload() {
        Core().addProcess((Process proc) {
            this.root = parseJSON(readText(path)).object();
            this.area = this.areas.find!(a => a.name == this.area.name).front;
            proc.kill();
        }, "stage update");
    }

    override void save() {
        write(path, root.toJSON(true));
    }

    void addCrystal(vec3 pos) {
        this.area.addCrystal(root[this.area.name], pos);
        this.save();
    }

    void addLight(vec3 pos) {
        this.area.addLight(root[this.area.name], pos);
        this.save();
    }

    private debug void addDebugActions() {
        import game.effect.Effect;
        import game.effect.StartEffect;

        Core().getKey().justPressed(KeyButton.KeyL).add(&reload);
        Core().getKey().justPressed(KeyButton.KeyP).add({
            Game.getPlayer().setCenter(this.area.debugPos);
        });

        Core().getKey().justPressed(KeyButton.KeyU).add({
            EffectManager().start(new StartEffect(this.stageName));
        });

        Core().getKey().justPressed(KeyButton.KeyT).add({
            wireVisible = !wireVisible;
            this.area.entity.traverse((Entity e) {
                e.mesh.mat.wrapCast!(WireframeMaterial).apply!(
                    mat => e.visible = wireVisible
                );
            });
        });

        Core().getKey().justPressed(KeyButton.KeyQ).add({
            auto pos = Game.getPlayer().getCenter();
            this.area.debugPos = pos;
            write(path, root.toJSON(true));
        });

        Core().addProcess((proc) {
            this.area.entity.traverse((Entity e) {
                e.mesh.mat.wrapCast!(WireframeMaterial).apply!(
                    mat => e.visible = wireVisible
                );
            });
        }, "po");
    }
}

struct Area {
    private size_t index;
    private JSONValue[] parent;

    struct Inst {
        Entity entity;
        Entity stageEntity;
        Entity characterEntity;
        Entity moveEntity;
        Entity crystalEntity;
        Entity lightEntity;
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
    }

    void create() {
        auto entity = new Entity;
        auto stageEntity = new Entity;
        auto characterEntity = new Entity;
        auto moveEntity = new Entity;
        auto crystalEntity = new Entity;
        auto lightEntity = new Entity;

        stageEntity.addChild(crystalEntity);
        entity.addChild(stageEntity);
        entity.addChild(characterEntity);
        entity.addChild(moveEntity);
        entity.addChild(lightEntity);

        insts[index] = Inst(entity, stageEntity, characterEntity, moveEntity, crystalEntity, lightEntity);

        entity.name = name ~" entity";
        crystalEntity.name = name ~" crystalEntity";
        stageEntity.name = name ~" stageEntity";
        characterEntity.name = name ~" characterEntity";
        moveEntity.name = name ~" moveEntity";
        lightEntity.name = name ~" lightEntity";
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
        this.stageEntity.addChild(m);
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
