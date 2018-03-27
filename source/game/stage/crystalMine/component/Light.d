module game.stage.crystalMine.component.Light;

struct Light {

    import std.json;
    import sbylib;


    private size_t index;
    private JSONValue[] parent;
    private Entity lightEntity;
    private static PointLight[][Entity] _lights;

    this(size_t index, JSONValue[] parent, Entity lightEntity) {
        this.index = index;
        this.parent = parent;
        this.lightEntity = lightEntity;

        this.pos = pos;
        this.color = color;
    }

    void create(size_t index) {
        auto light = new PointLight(pos, color);
        lightEntity.addChild(light);

        lights ~= light;

        auto parent = this.parent;
        auto lightEntity = this.lightEntity;
        light.pos.addChangeCallback({
            vec3 p = light.pos;
            Light(index, parent, lightEntity).pos = p;
        });
    }
    
    auto light() {
        while (lights.length <= index) create(lights.length);
        return lights[index];
    }

    auto obj() {
        return parent[index].object();
    }

    auto ref lights() {
        if (lightEntity !in _lights) _lights[lightEntity] = [];
        return _lights[lightEntity];
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
