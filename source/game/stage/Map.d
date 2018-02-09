module game.stage.Map;

import sbylib;
import game.Game;
import model.xfile.loader;
import game.character;
import std.json, std.file, std.stdio;;
import game.stage.StageMaterial;
import game.stage.CrystalMaterial;

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

class Map {
    private Entity polygons;
    private string stageDataPath;

    alias getPolygon this;

    this() {
        this.polygons = new Entity;
        Game.getWorld3D().add(this.polygons);
    }

    void testStage() {
        auto makePolygon = (vec3[4] p) {
            auto polygons = [
                new CollisionPolygon([p[0], p[1], p[2]]),
                new CollisionPolygon([p[0], p[2], p[3]])
            ];
            auto mat = new CheckerMaterial!(NormalMaterial, UvMaterial);
            mat.size = 0.118;
            auto geom0 = polygons[0].createGeometry();
            geom0.vertices[0].uv = vec2(1,0);
            geom0.vertices[1].uv = vec2(1,1);
            geom0.vertices[2].uv = vec2(0,1);
            geom0.updateBuffer();
            auto geom1 = polygons[1].createGeometry();
            geom1.vertices[0].uv = vec2(1,0);
            geom1.vertices[1].uv = vec2(0,1);
            geom1.vertices[2].uv = vec2(0,0);
            geom1.updateBuffer();

            Entity e0 = new Entity(geom0, mat, polygons[0]);
            Entity e1 = new Entity(geom1, mat, polygons[1]);
            this.polygons.addChild(e0);
            this.polygons.addChild(e1);
        };
        makePolygon([vec3(20,0,-20),vec3(20,0,60), vec3(-20, 0, +60), vec3(-20, 0, -20)]);
        makePolygon([vec3(20,0,10),vec3(20,10,40), vec3(-20, 10, +40), vec3(-20, 0, 10)]);
    }

    void testStage2() {
        import std.algorithm, std.array;
        this.stageDataPath = "Resource/stage/Stage1.json";

        auto loader = new XLoader;
        auto jsonData = parseJSON(readText(stageDataPath)).object();
        auto models = jsonData["Model"].array().map!(a => a.str()).array;
        writeln("Model Load Start. ModelPath is ", models[0]);
        {
            auto model = loader.load(ModelPath(models[0])).buildEntity(new StageMaterialBuilder);
            this.polygons.addChild(model);
            writeln("Model was Loaded.");
        }

        import std.concurrency;
        import core.thread;
        spawn(function (immutable(string[]) models) {
            foreach (i; 1..models.length) {
                Thread.sleep(1000.msecs);
                writeln("Model Load Start. ModelPath is ", models[i]);
                auto loader = new XLoader();
                auto loaded = loader.load(ModelPath(models[i]));
                writeln("Model was Loaded.");
                ownerTid.send(loaded);
            }
        }, models.idup);
        Core().addProcess((Process proc) {
            import model.xfile.loader;
            receiveTimeout(0.msecs,
                (immutable XEntity entity) {
                    import std.stdio;
                    writeln("received");
                    auto model = entity.buildEntity(new StageMaterialBuilder);
                    polygons.addChild(model);
                    Game.getWorld3D().add(model);
                    model.buildBVH();
                    model.traverse!((Entity e) {
                        auto name = e.mesh.mat.wrapCast!(StageMaterial).name;
                        if (name.isNone) return;
                        e.setUserData(name.get);
                    });
                }
            );
        }, "addModel");

        writeln("BVH constructing...");
        foreach (model; this.polygons.getChildren) {
            model.buildBVH();
            model.traverse!((Entity e) {
                auto name = e.mesh.mat.wrapCast!(StageMaterial).name;
                if (name.isNone) return;
                e.setUserData(name.get);
            });
        }
        writeln("BVH construction was finished.");

        addNPC(jsonData["NPC"].array());

        addLight();

    }

    private void addLight() {
        auto loader = new XLoader;
        auto loaded = loader.load(ModelPath("crystal.x"));
        void exec() {
            auto jsonData = parseJSON(readText("Resource/stage/Stage1.json")).object();
            Game.getWorld3D().clearPointLight();
            foreach (data; jsonData["Lights"].array) {
                auto obj = data.object();
                auto pos = vec3(obj["pos"].as!(float[]));
                auto color = vec3(obj["color"].as!(float[]));
                Game.getWorld3D().addPointLight(PointLight(pos, color));
            }
            Game.getWorld3D().clear("Crystal");
            foreach (data; jsonData["Crystal"].array()) {
                auto obj = data.object();
                auto pos = vec3(obj["pos"].as!(float[]));
                auto color = vec3(obj["color"].as!(float[]));
                auto model = loaded.buildEntity(new StageMaterialBuilder);
                model.pos = pos;
                this.polygons.addChild(model);
                Game.getWorld3D().add(model);
                Game.getWorld3D().addPointLight(PointLight(pos, color));
            }
        }

        Core().getKey.justPressed(KeyButton.KeyL).add(&exec);
        exec();
    }

    private void addNPC(JSONValue[] jsonData) {
        import std.algorithm : map, each;
        import std.array;
        import std.conv;
        Character[] characters;
        foreach (data; jsonData) {
            auto obj = data.object();
            auto chara = new Character(Game.getWorld3D(), obj["serif"].str().to!dstring);
            chara.setCenter(vec3(obj["pos"].as!(float[])));
            characters ~= chara;
            Game.getPlayer().collisionEntities ~= chara.collisionArea;
        }
        Core().addProcess((proc) {
            characters.each!(c => c.step());
        }, "player update");
    }

    Entity getPolygon() {
        return this.polygons;
    }
}
