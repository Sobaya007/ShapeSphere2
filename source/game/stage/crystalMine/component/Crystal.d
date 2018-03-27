module game.stage.crystalMine.component.Crystal;

struct Crystal {

    import std.json, std.typecons;
    import sbylib;

    private size_t index;
    private JSONValue[] parent;
    private Entity crystalEntity;
    private static Tuple!(Entity, PointLight)[][Entity] _reserved;

    this(size_t index, JSONValue[] parent, Entity crystalEntity) {
        this.index = index;
        this.parent = parent;
        this.crystalEntity = crystalEntity;

        this.pos = pos;
        this.color = color;
    }

    void create(size_t index) {
        auto loaded = XLoader().load(ModelPath("crystal.x"));

        import game.stage.crystalMine.StageMaterial;
        auto entity = loaded.buildEntity(StageMaterialBuilder());
        entity.buildCapsule();

        auto light = new PointLight(vec3(0), vec3(0));
        entity.addChild(light);

        crystalEntity.addChild(entity);

        reserved ~= tuple(entity, light);

        auto parent = this.parent;
        auto crystalEntity = this.crystalEntity;
        entity.pos.addChangeCallback({
            vec3 p = entity.pos;
            Crystal(index, parent, crystalEntity).pos = p;
        });

        import game.tool.manipulator;
        entity.setUserData(new ManipulatorTarget); // temp
    }

    auto ref reserved() {
        if (crystalEntity !in _reserved) _reserved[crystalEntity] = [];
        return _reserved[crystalEntity];
    }

    Entity entity() {
        while (reserved.length <= index) create(reserved.length);
        return reserved[index][0];
    }

    PointLight light() {
        while (reserved.length <= index) create(reserved.length);
        return reserved[index][1];
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

    vec3 color() {
        return vec3(obj["color"].as!(float[]));
    }

    void color(vec3 p) {
        obj["color"] = p.array[];
        light.diffuse = color;
    }

    void remove() {
        this.entity.remove();
        this.entity.destroy();
    }
}
