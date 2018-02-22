module game.stage.Stage1;

import std.json, std.algorithm, std.array, std.file, std.range;

import sbylib;

import game.Game;
import game.character;
import game.stage.StageMaterial;
import game.stage.CrystalMaterial;
import game.stage.Stage;
import model.xfile.loader;
import std.concurrency;
import core.thread;

class Stage1 : Stage {
    private Area[] areas;

    private Area area;

    private bool paused;

    private TypedEntity!(GeometryRect, ColorMaterial) fadeRect;

    enum path = "Resource/stage/Stage1.json";

    this() {
        auto obj = parseJSON(readText(path)).object();
        foreach (k, v; obj) {
            this.areas ~= new Area(k, v.object());
        }
        this.area = this.areas[0];
        Game.getWorld3D().add(this.area.entity);
        this.area.load();

        Core().addProcess(&step, "Stage1");

        Core().getKey().justPressed(KeyButton.KeyL).add(&update);

        Core().getKey().justPressed(KeyButton.KeyP).add({
            Game.getPlayer().setCenter(this.area.startPos);
        });

        this.fadeRect = makeColorEntity(vec4(0), 2,2);
        this.fadeRect.config.renderGroupName = "transparent";
        this.fadeRect.config.depthWrite = false;
        this.fadeRect.pos.z = 1;
        Game.getWorld2D().add(this.fadeRect);
    }

    void step() {
        if (paused) return;
        this.area.step();
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

    override void transit(string name) {
        paused = true;
        AnimationManager().startAnimation(
            new Animation!vec4(color => this.fadeRect.color = color,
                setting(
                    vec4(0,0,0,0),
                    vec4(0,0,0,1),
                    60,
                    Ease.linear
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
                        60,
                        Ease.linear
                    )
                )
            );
        });
    }

    void update() {
        Core().addProcess((Process proc) {
            PointLightManager().clear();
            auto value = parseJSON(readText(path)).object();
            foreach (name, v; value) {
                import std.algorithm;
                this.areas.find!(a => a.name == name).front.update(v.object());
            }
            proc.kill();
        }, "stage update");
    }

    void addCrystal(vec3 pos) {
        auto root = parseJSON(readText(path));
        this.area.addCrystal(root[this.area.name], pos);
        write(path, root.toJSON(true));
        Core().addProcess((proc) { update(); proc.kill(); }, "update stage");
    }

    void addLight(vec3 pos) {
        auto root = parseJSON(readText(path));
        this.area.addLight(root[this.area.name], pos);
        write(path, root.toJSON(true));
        Core().addProcess((proc) { update(); proc.kill(); }, "update stage");
    }
}

class Area {
    private string name;
    private Entity entity;
    private Entity stageEntity;
    private Entity characterEntity;
    private Entity moveEntity;
    private Entity crystalEntity;
    private Entity lightEntity;
    private Move[] moves;
    private Light[] lights;
    private Crystal[] crystals;
    private Character[] characters;
    private vec3 startPos;
    private string[] paths;

    this(string name, JSONValue[string] obj) {
        this.entity = new Entity;
        this.stageEntity = new Entity;
        this.characterEntity = new Entity;
        this.moveEntity = new Entity;
        this.crystalEntity = new Entity;
        this.lightEntity = new Entity;
        this.name = name;
        this.startPos = vec3(obj["startPos"].as!(float[]));
        this.moves = obj["Move"].array().map!(v => new Move(v.object())).array;
        this.lights = obj["Lights"].array().map!(v => new Light(v.object())).array;
        this.crystals = obj["Crystals"].array().map!(v => new Crystal(v.object())).array;
        this.characters = obj["NPC"].array().map!(v => new Character(v.object())).array;

        this.characters.each!(c => this.characterEntity.addChild(c.entity));
        this.characters.each!(c => Game.getPlayer().collisionEntities ~= c.collisionArea);

        this.moves.each!(m => this.moveEntity.addChild(m.entity));

        this.crystals.each!(c => this.crystalEntity.addChild(c.entity));

        this.lights.each!(c => this.lightEntity.addChild(c.light));

        this.entity.addChild(this.stageEntity);
        this.entity.addChild(this.characterEntity);
        this.entity.addChild(this.moveEntity);
        this.entity.addChild(this.crystalEntity);
        this.entity.addChild(this.lightEntity);

        this.paths = obj["Model"].as!(string[]);
    }

    void load() {
        import std.concurrency, std.stdio;
        import core.thread;
        spawn(function (immutable(string[]) paths) {
            auto loader = new XLoader();
            foreach (path; paths) {
                writeln("Model Load Start. ModelPath is ", path);
                auto loaded = loader.load(ModelPath(path));
                writeln("Model was Loaded.");
                ownerTid.send(loaded);
                Thread.sleep(1000.msecs);
            }
        }, paths.idup);
    }

    void step() {
        foreach (path; paths) {
            receive(&onReceive);
        }
        paths = null;
        this.characters.each!(c => c.step);
        Game.getPlayer().step();
    }

    void onReceive(immutable XEntity entity) {
        import model.xfile.loader;
        import std.stdio;
        writeln("received");
        auto m = entity.buildEntity(new StageMaterialBuilder);
        this.stageEntity.addChild(m);
        m.buildBVH();
        m.traverse!((Entity e) {
            auto name = e.mesh.mat.wrapCast!(StageMaterial).name;
            if (name.isNone) return;
            e.setUserData(name.get);
        });
        writeln("BVH construction was finished.");
    }

    void update(JSONValue[string] obj) {
        this.lightEntity.traverse!((Entity e) => e.destroy());
        this.crystalEntity.traverse!((Entity e) => e.destroy());
        this.lightEntity.clearChildren();
        this.crystalEntity.clearChildren();
        this.lights = obj["Lights"].array().map!(v => new Light(v.object())).array;
        this.crystals = obj["Crystals"].array().map!(v => new Crystal(v.object())).array;
        this.lights.each!(c => this.lightEntity.addChild(c.light));
        this.crystals.each!(c => this.crystalEntity.addChild(c.entity));
    }

    void addCrystal(ref JSONValue area, vec3 pos) {
        auto obj = parseJSON("{}");
        obj["pos"] = JSONValue(pos.array[]);
        obj["color"] = JSONValue(vec3(1).array[]);
        area["Crystals"].array ~= obj;
    }

    void addLight(ref JSONValue area, vec3 pos) {
        auto obj = parseJSON("{}");
        obj["pos"] = JSONValue(pos.array[]);
        obj["color"] = JSONValue(vec3(1).array[]);
        area["Lights"].array ~= obj;
    }
}

class Move {
    Shape shape;
    const string arrivalName;

    this(JSONValue[string] obj) {
        this.shape = new Shape(obj["Shape"].object());
        shape.setUserData(this);
        this.arrivalName = obj["to"].str();
    }

    alias shape this;
}

class Shape {
    Entity entity;

    this(JSONValue[string] obj) {
        assert(obj["kind"].str() == "Sphere");
        auto center = vec3(obj["center"].as!(float[]));
        auto radius = obj["radius"].as!(float);
        debug {
            this.entity = makeEntity(Sphere.create(radius, 2), new WireframeMaterial(vec4(1)), new CollisionCapsule(radius, vec3(0), vec3(0)));
        } else {
            this.entity = makeEntity(new CollisionCapsule(radius, center, center));
        }
        this.entity.pos = center;
    }

    alias entity this;
}

class Light {

    PointLight light;

    this(JSONValue[string] obj) {
        auto pos = vec3(obj["pos"].as!(float[]));
        auto color = vec3(obj["color"].as!(float[]));
        this.light = new PointLight(pos, color);
        Game.getWorld3D().add(this.light);
    }

    void update(JSONValue[string] obj) {
        auto pos = vec3(obj["pos"].as!(float[]));
        auto color = vec3(obj["color"].as!(float[]));
        this.light.pos = pos;
        this.light.diffuse = color;
    }

    void remove() {
    }
}

class Crystal {
    private Entity entity;
    private PointLight light;

    this(JSONValue[string] obj) {
        auto pos = vec3(obj["pos"].as!(float[]));
        auto color = vec3(obj["color"].as!(float[]));
        auto loader = new XLoader;
        auto loaded = loader.load(ModelPath("crystal.x"));

        this.entity = loaded.buildEntity(new StageMaterialBuilder);
        this.entity.pos = pos;

        this.light = new PointLight(vec3(0), color);
        this.entity.addChild(light);
    }

    void update(JSONValue[string] obj) {
        auto pos = vec3(obj["pos"].as!(float[]));
        auto color = vec3(obj["color"].as!(float[]));

        this.entity.pos = pos;
        light.pos = pos;
        light.diffuse = color;
    }

    void remove() {
        this.entity.remove();
        this.entity.destroy();
    }
}

class StageMaterialBuilder : MaterialBuilder {
    override Material buildMaterial(immutable(XMaterial) xmat) {
        import std.string;
        if (xmat.name.startsWith("Crystal")) return new CrystalMaterial;
        auto material = new StageMaterial();
        material.diffuse = xmat.diffuse.xyz;
        material.specular = xmat.specular;
        material.ambient = vec4(xmat.ambient, 1.0);
        material.power = xmat.power;
        material.name = xmat.name;
        return material;
    }
}

