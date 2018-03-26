module game.stage.crystalMine.component.Character;

struct Character {

    import std.json, std.typecons;
    import sbylib;

    private size_t index;
    private JSONValue[] parent;
    private Entity characterEntity;
    import game.character.Character : Chara = Character;
    private static Chara[][Entity] _characters;

    alias character this;

    this(size_t index, JSONValue[] parent, Entity characterEntity) {
        this.index = index;
        this.parent = parent;
        this.characterEntity = characterEntity;
    }

    auto ref characters() {
        if (characterEntity !in _characters) _characters[characterEntity] = [];
        return _characters[characterEntity];
    }

    Chara character() {
        while (characters.length <= index) {
            auto c = new Chara;
            c.serif = serif;
            c.setCenter(pos);
            characters ~= c;
            characterEntity.addChild(c.entity);
            import game.Game;
            Game.getPlayer().collisionEntities ~= c.collisionArea;
        }
        return characters[index];
    }

    auto obj() {
        return parent[index].object();
    }
    
    vec3 pos() {
        return vec3(obj["pos"].as!(float[]));
    }

    void pos(vec3 p) {
        obj["pos"] = p.array[];
        character.setCenter(p);
    }

    dstring serif() {
        return obj["serif"].as!dstring;
    }

    void serif(dstring serif) {
        obj["serif"] = serif;
        character.serif = serif;
    }
}
