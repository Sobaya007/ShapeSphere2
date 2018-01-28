module game.stage.Map;

import sbylib;
import game.Game;
import model.xfile.loader;
import game.character;
import std.json, std.file, std.stdio;;
import game.stage.StageMaterial;

class StageMaterialBuilder : MaterialBuilder {
    override Material buildMaterial(immutable(XMaterial) xmat) {
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
        auto jsonData = parseJSON(readText("Resource/stage/Stage1.json")).object();

        import std.algorithm, std.array;
        auto models = jsonData["Model"].array().map!(a => a.str()).array;
        auto mat = new StageMaterialBuilder;
        writeln("Model Load Start. ModelPath is ", models[0]);
        addModel(models[0], mat);
        writeln("Model was Loaded.");
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
                    model.buildBVH((Entity bvh) {
                        bvh.getParent().getMesh.apply!((Mesh m) {
                            if (auto stageMat = cast(StageMaterial)m.mat) {
                                bvh.getParent.setUserData(stageMat.name);
                            }
                        });
                    });
                    //proc.kill();
                }
            );
        }, "addModel");

        writeln("BVH constructing...");
        foreach (model; this.polygons.getChildren) {
            model.buildBVH((Entity bvh) {
                bvh.getParent().getMesh.apply!((Mesh m) {
                    if (auto stageMat = cast(StageMaterial)m.mat) {
                        bvh.getParent.setUserData(stageMat.name);
                    }
                });
            });
        }
        writeln("BVH construction was finished.");

        addNPC(jsonData["NPC"].array());
    }

    private void addModel(string modelPath, MaterialBuilder builder) {
        auto loader = new XLoader();
        auto model = loader.load(ModelPath(modelPath)).buildEntity(builder);
        this.polygons.addChild(model);
    }

    private void addModelFromAnotherThread(string modelPath, MaterialBuilder builder) {
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
