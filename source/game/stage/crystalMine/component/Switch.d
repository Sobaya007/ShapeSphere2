module game.stage.crystalMine.component.Switch;

struct Switch {

    import std.json;
    import sbylib;
    import game.entity.SwitchEntity;

    private size_t index;
    private JSONValue[] parent;
    private static SwitchEntity[] _entities;
    private Entity switchEntity;

    this(size_t index, JSONValue[] parent, Entity switchEntity) {
        this.index = index;
        this.parent = parent;
        this.switchEntity = switchEntity;
        this.pos = pos;
    }

    void create(size_t index) {
        auto entity = new SwitchEntity;
        _entities ~= entity;
        switchEntity.addChild(entity);
        entity.setUserData(this);
    }

    ref SwitchEntity[] entities() {
        while (_entities.length <= this.index) create(_entities.length);
        return _entities;
    }

    auto obj() {
        return parent[index].object();
    }

    SwitchEntity entity() {
        return entities[index];
    }

    auto pos() {
        return vec3(obj["pos"].as!(float[]));
    }

    auto pos(vec3 c) {
        foreach (i; 0..3) obj["pos"].array[i] = c[i];
        this.entity.pos = c;
    }
}
