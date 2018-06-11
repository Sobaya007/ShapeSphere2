module game.stage.crystalMine.component.Move;

struct Move {

    import std.json;
    import sbylib;
    import game.stage.crystalMine.component.Shape;

    private size_t index;
    private JSONValue[] parent;
    package Entity moveEntity;

    this(size_t index, JSONValue[] parent, Entity moveEntity) {
        this.index = index;
        this.parent = parent;
        this.moveEntity = moveEntity;
        this.arrivalName = arrivalName;
        shape.setUserData("Move", this);
    }

    auto obj() {
        return parent[index].object();
    }

    Shape shape() {
        return Shape(index, obj["Shape"].object(), this);
    }

    string arrivalName() {
        return obj["to"].str();
    }

    void arrivalName(string s) {
        obj["to"] = s;
    }
}
