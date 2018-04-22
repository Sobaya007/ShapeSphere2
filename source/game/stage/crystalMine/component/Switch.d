module game.stage.crystalMine.component.Switch;

struct Switch {

    import std.json;
    import sbylib;
    import game.entity.SwitchEntity;

    private size_t index;
    private JSONValue[] parent;
    private static SwitchEntity[][Entity] _entities;
    private Entity switchEntity;

    this(size_t index, JSONValue[] parent, Entity switchEntity) {
        this.index = index;
        this.parent = parent;
        this.switchEntity = switchEntity;
        this.pos = pos;
        this.angle = angle;
    }

    void create(size_t index) {
        auto entity = new SwitchEntity;
        entities ~= entity;
        switchEntity.addChild(entity);
        entity.setUserData(this);
        entity.event = {
            import game.Game;
            Game.getPlayer().camera.focus(entity);
            AnimationManager().startAnimation(
                sequence(
                    wait(90.frame),
                    single({ Game.getPlayer().camera.chase(); })
                )
            );
        };
    }

    ref SwitchEntity[] entities() {
        if (switchEntity !in _entities) _entities[switchEntity] = [];
        return _entities[switchEntity];
    }

    auto obj() {
        return parent[index].object();
    }

    SwitchEntity entity() {
        while (entities.length <= index) create(entities.length);
        return entities[index];
    }

    auto pos() {
        return vec3(obj["pos"].as!(float[]));
    }

    void pos(vec3 c) {
        foreach (i; 0..3) obj["pos"].array[i] = c[i];
        this.entity.pos = c;
    }

    auto angle() {
        return obj["angle"].as!(float).deg;
    }

    void angle(Degree a) {
        obj["angle"] = a.deg;
        this.entity.rot = mat3.axisAngle(vec3(0,1,0), a.rad);
    }

    auto focus() {
        return obj["focus"].str();
    }
}
