module game.console.selections.WorldSelection;

import sbylib;
import game.console.selections.Selectable;
import game.console.selections.EntitySelection;

class WorldSelection : Selectable {

    private World world;

    this(World world) {this.world = world;}

    override string[] childNames() {
        import std.algorithm : filter, map;
        import std.array : array;
        return world.getEntities.filter!(e => e.getParent.isNone).map!(e => e.name).array ~ "camera";
    }

    override Selectable[] findChild(string name) {
        import std.algorithm : filter, map;
        import std.array : array;

        if (name == "camera") return [cast(Selectable)new EntitySelection(world.getCamera)];
        return world.getEntities.filter!(e => e.getParent.isNone).filter!(e => e.name == name).map!(e => cast(Selectable)new EntitySelection(e)).array;
    }

    override string getInfo() {
        import std.algorithm : sort, group, map;
        import std.format;
        import std.array : join, split;

        return world.toString((Entity e) => e.name, false).split("\n").sort.group.map!(p => p[1] == 1 ? p[0] : format!"%s[%d]"(p[0], p[1])).join("\n");
    }

    override Maybe!string order(string) {
        return None!string;
    }

    override string assign(string) {
        return "Cannot assign to World.";
    }
}
