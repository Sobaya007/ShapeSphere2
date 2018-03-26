module game.stage.crystalMine.component.Shape;

struct Shape {

    import std.json;
    import sbylib;
    import game.stage.crystalMine.component.Move;

    private size_t index;
    private JSONValue[string] obj;
    private Move move;
    private static Entity[][Entity] _entities;

    this(size_t index, JSONValue[string] obj, Move move) {
        this.index = index;
        this.obj = obj;
        this.move = move;
        assert(obj["kind"].str() == "Sphere");

        this.center = center;
        this.radius = radius;
    }

    ref Entity[] entities() {
        if (move.moveEntity !in _entities) _entities[move.moveEntity] = [];
        return _entities[move.moveEntity];
    }

    Entity entity() {
        while (entities.length <= index) {
            auto capsule = new CollisionCapsule(radius, vec3(0), vec3(0));
            debug {
                auto entity = makeEntity(Sphere.create(radius, 2), new WireframeMaterial(vec4(1)), capsule);
                entity.name = "Move:"~move.arrivalName;
            } else {
                auto entity = makeEntity(capsule);
            }
            entities ~= entity;
            entity.setUserData(move.arrivalName);
            this.center = center;
            move.moveEntity.addChild(entity);
        }
        return entities[index];
    }

    auto center() {
        return vec3(obj["center"].as!(float[]));
    }

    auto center(vec3 c) {
        foreach (i; 0..3) obj["center"].array[i] = c[i];
        this.entity.pos = c;
    }

    auto radius() {
        return obj["radius"].as!(float);
    }

    auto radius(float r) {
        obj["radius"] = r;
        auto capsule = this.entity.colEntry.getGeometry.wrapCast!(CollisionCapsule);
        if (capsule.isJust) {
            capsule.get().radius = r;
        }
    }

    alias entity this;
}
