module game.stage.crystalMine.component.Bomb;

import sbylib;
import std.math;

struct Bomb {

    import std.json, std.typecons;
    import sbylib;

    private size_t index;
    private JSONValue[] parent;
    private Entity bombEntity;
    private static Entity[][Entity] _reserved;

    this(size_t index, JSONValue[] parent, Entity bombEntity) {
        this.index = index;
        this.parent = parent;
        this.bombEntity = bombEntity;

        this.pos = pos;
    }

    void create(size_t index) {

        auto e = new BombEntity;

        bombEntity.addChild(e);

        reserved ~= e;

        auto parent = this.parent;
        auto bombEntity = this.bombEntity;
        entity.pos.addChangeCallback({
            vec3 p = entity.pos;
            Bomb(index, parent, bombEntity).pos = p;
        });

        import game.tool.manipulator;
        entity.setUserData(new ManipulatorTarget); // temp
    }

    auto ref reserved() {
        if (bombEntity !in _reserved) _reserved[bombEntity] = [];
        return _reserved[bombEntity];
    }

    Entity entity() {
        while (reserved.length <= index) create(reserved.length);
        return reserved[index];
    }

    auto obj() {
        return parent[index].object();
    }

    vec3 pos() {
        return vec3(obj["pos"].as!(float[]));
    }

    void pos(vec3 p) {
        obj["pos"] = p.array[];
        entity.pos = pos;
    }

    void remove() {
        this.entity.remove();
        this.entity.destroy();
    }
}

class BombEntity {
    Entity entity;

    alias entity this;

    this() {
        auto entity = makeEntity(Dodecahedron.create(), new BombMaterial);
        auto light = new PointLight(vec3(0), vec3(0));
        light.visible = false;
        entity.buildSphere();
        entity.addChild(light);
        this.entity = entity;
        this.scale *= 3;

        Core().addProcess({
            auto s1 = sin(entity.time * 0.03) * 0.4 + 0.6;
            auto s2 = cos(entity.time * 0.0433456781) * 0.4 + 0.6;
            entity.lightScale = (s1 + s2) / 2;
            light.diffuse = vec3(1, 0.7, 0.1) * entity.lightScale;
        }, "bomb");
    }
}

class BombMaterial : Material {
    mixin ConfigureMaterial!(q{{"useGeometryShader" : true}});

    utexture noise;
    ufloat time;
    ufloat lightScale;

    this() {
        mixin(autoAssignCode);
        super();

        this.noise = ImageLoader.load(ImagePath("noise.jpg")).generateTexture();
        this.time = 0;
        Core().addProcess({ this.time++; }, "bomb");
        this.lightScale = 1;
    }
}
