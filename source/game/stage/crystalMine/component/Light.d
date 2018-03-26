module game.stage.crystalMine.component.Light;

struct Light {

    import std.json;
    import sbylib;

    private static PointLight[][Entity] _lights;

    private JSONValue[] parent;
    private size_t index;
    private Entity lightEntity;

    this(size_t index, JSONValue[] parent, Entity lightEntity) {
        this.parent = parent;
        this.index = index;
        this.lightEntity = lightEntity;
        this.pos = pos;
        this.color = color;

        this.light.pos.addChangeCallback({
            this.pos = this.light.pos;
        });
    }

    auto obj() {
        return parent[index].object();
    }

    auto ref lights() {
        if (lightEntity !in _lights) _lights[lightEntity] = [];
        return _lights[lightEntity];
    }
    
    auto light() {
        while (lights.length <= index) {
            auto light = new PointLight(pos, color);
            lights ~= light;
            lightEntity.addChild(light);
        }
        return lights[index];
    }

    vec3 pos() {
        return vec3(obj["pos"].as!(float[]));
    }

    void pos(vec3 p) {
        obj["pos"] = p.array[];
        light.pos = pos;
    }

    vec3 color() {
        return vec3(obj["color"].as!(float[]));
    }

    void color(vec3 c) {
        obj["color"] = c.array[];
        light.diffuse = c;
    }

    alias light this;
}
