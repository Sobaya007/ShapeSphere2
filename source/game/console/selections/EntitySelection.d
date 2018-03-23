module game.console.selections.EntitySelection;

import sbylib;
import game.console.selections.Selectable;
import game.console.selections.MatrixSelection;
import game.console.selections.VectorSelection;

class EntitySelection : Selectable {

    private Entity entity;

    this(Entity entity) {this.entity = entity;}

    override string[] childNames() {
        import std.algorithm : map;
        import std.array : array;

        return entity.getChildren.map!(e => e.name).array ~ ["pos", "rot", "scale"];
    }

    override Selectable[] findChild(string name) {
        import std.algorithm : filter, map;
        import std.array : array;

        if (name == "pos") return [new VectorSelection!true(entity.pos)];
        if (name == "rot") return [new MatrixSelection(entity.rot)];
        if (name == "scale") return [new VectorSelection!true(entity.scale)];
        auto res = entity.getChildren.filter!(e => e.name == name).map!(e => cast(Selectable)new EntitySelection(e)).array;
        return res;
    }

    override string getInfo() {
        return entity.toString(false);
    }

    override Maybe!string order(string) {
        return None!string;
    }

    override string assign(string) {
        return "Cannot assign to Entity.";
    }
}

