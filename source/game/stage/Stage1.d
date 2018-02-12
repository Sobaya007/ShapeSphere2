module game.stage.Stage1;

import std.json, std.algorithm, std.array, std.file;

import sbylib;

import game.Game;
import game.character;
import game.stage.StageMaterial;
import game.stage.CrystalMaterial;
import game.stage.Stage;
import model.xfile.loader;
import std.concurrency;
import core.thread;

class Stage1 : Stage{
    private Area[] areas;

    private Area area;

    this() {
        auto path = "Resource/stage/Stage1.json";
        auto value = parseJSON(readText(path));
        this.areas = value.array().map!(v => new Area(v.object())).array;
        this.area = this.areas[0];
        Game.getWorld3D().add(this.area.stageEntity);

        Core().addProcess(&step, "Stage1");
    }

    void step() {
        areas.each!(area => area.step());
    }

    override Entity getStageEntity() {
        return this.area.stageEntity;
    }

    override Entity getCharacterEntity() {
        return this.area.characterEntity;
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

    this(JSONValue[string] obj) {
        this.stageEntity = new Entity;
        this.characterEntity = new Entity;
        this.name = obj["Name"].str();
        this.moves = obj["Move"].array().map!(v => new Move(v.object())).array;
        this.lights = obj["Lights"].array().map!(v => new Light(v.object())).array;
        this.crystals = obj["Crystals"].array().map!(v => new Crystal(v.object())).array;
        this.characters = obj["NPC"].array().map!(v => new Character(v.object())).array;

        this.characters.each!(c => this.characterEntity.addChild(c.entity));

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
        auto pos = vec3(obj["pos"].as!(float[]));
        auto color = vec3(obj["color"].as!(float[]));
        Game.getWorld3D().addPointLight(PointLight(pos, color));
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

