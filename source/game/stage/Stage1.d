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

    enum path = "Resource/stage/Stage1.json";

    this() {
        auto obj = parseJSON(readText(path)).object();
        foreach (k, v; obj) {
            this.areas ~= new Area(k, v.object());
        }
        this.area = this.areas[0];
        Game.getWorld3D().add(this.area.stageEntity);
        Game.getWorld3D().add(this.area.characterEntity);

        Core().addProcess(&step, "Stage1");

        Core().getKey().justPressed(KeyButton.KeyL).add(&update);
    }

    void step() {
        this.area.step();
    }

    override Entity getStageEntity() {
        return this.area.stageEntity;
    }

    override Entity getCharacterEntity() {
        return this.area.characterEntity;
    }

    void update() {
        Game.getWorld3D.clearPointLight();
        auto value = parseJSON(readText(path)).object();
        foreach (name, v; value) {
            import std.algorithm;
            this.areas.find!(a => a.name == name).front.update(v.object());
        }
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
    private Entity stageEntity;
    private Entity characterEntity;
    private Move[] moves;
    private Light[] lights;
    private Crystal[] crystals;
    private Character[] characters;

    this(string name, JSONValue[string] obj) {
        this.stageEntity = new Entity;
        this.characterEntity = new Entity;
        this.name = name;
        this.moves = obj["Move"].array().map!(v => new Move(v.object())).array;
        this.lights = obj["Lights"].array().map!(v => new Light(v.object())).array;
        this.crystals = obj["Crystals"].array().map!(v => new Crystal(v.object())).array;
        this.characters = obj["NPC"].array().map!(v => new Character(v.object())).array;

        this.characters.each!(c => this.characterEntity.addChild(c.entity));
        this.characters.each!(c => Game.getPlayer().collisionEntities ~= c.collisionArea);

        auto paths = obj["Model"].as!(string[]);

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
        receiveTimeout(0.msecs, &onReceive);
        this.characters.each!(c => c.step);
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
        updateLights(obj["Lights"].array());
        updateCrystals(obj["Crystals"].array());
    }

    void updateLights(JSONValue[] data) {
        foreach (l, v; zip(this.lights, data)) {
            l.update(v.object());
        }
        if (this.lights.length < data.length) {
            this.lights ~= data[this.lights.length..$].map!(v => new Light(v.object())).array;
        }
        if (data.length < this.lights.length) {
            this.lights[data.length..$].each!(l => l.remove());
            this.lights = this.lights[0..data.length];
        }
    }

    void updateCrystals(JSONValue[] data) {
        foreach (l, v; zip(this.crystals, data)) {
            l.update(v.object());
        }
        if (this.crystals.length < data.length) {
            this.crystals ~= data[this.crystals.length..$].map!(v => new Crystal(v.object())).array;
        }
        if (data.length < this.crystals.length) {
            this.crystals[data.length..$].each!(l => l.remove());
        }
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
    private Shape shape;
    private string arrivalName;

    this(JSONValue[string] obj) {
        this.shape = new Shape(obj["Shape"].object());
        this.arrivalName = obj["to"].str();
    }
}

class Shape {
    private Entity entity;

    this(JSONValue[string] obj) {
        assert(obj["kind"].str() == "Sphere");
        auto center = vec3(obj["center"].as!(float[]));
        auto radius = obj["radius"].as!(float);
        this.entity = makeEntity(new CollisionCapsule(radius, center, center));
    }
}

class Light {

    this(JSONValue[string] obj) {
        update(obj);
    }

    void update(JSONValue[string] obj) {
        auto pos = vec3(obj["pos"].as!(float[]));
        auto color = vec3(obj["color"].as!(float[]));
        Game.getWorld3D().addPointLight(PointLight(pos, color));
    }

    void remove() {
    }
}

class Crystal {
    private Entity entity;

    this(JSONValue[string] obj) {
        auto pos = vec3(obj["pos"].as!(float[]));
        auto color = vec3(obj["color"].as!(float[]));
        auto loader = new XLoader;
        auto loaded = loader.load(ModelPath("crystal.x"));

        this.entity = loaded.buildEntity(new StageMaterialBuilder);
        this.entity.pos = pos;
        Game.getWorld3D().add(entity);
        Game.getWorld3D().addPointLight(PointLight(pos, color));
    }

    void update(JSONValue[string] obj) {
        auto pos = vec3(obj["pos"].as!(float[]));
        auto color = vec3(obj["color"].as!(float[]));

        this.entity.pos = pos;
        Game.getWorld3D().addPointLight(PointLight(pos, color));
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

