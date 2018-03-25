module game.console.selections.WorldSelection;
import sbylib;
import game.console.selections.Selectable;
import game.console.selections.EntitySelection;

class WorldSelection : Selectable {

    private string mName;
    private World world;

    this(string name, World world) {
        this.mName = name;
        this.world = world;
    }

    mixin ImplCountChild!(true);

    override string name() {
        return mName;
    }

    override Selectable[] childs() {
        import std.algorithm : filter, map;
        import std.array : array;

        return [cast(Selectable)new EntitySelection(world.getCamera)]
        ~ world.getEntities.filter!(e => e.getParent.isNone).map!(e => cast(Selectable)new EntitySelection(e)).array;
    }

    override string getInfo() {
        import std.algorithm : sort, group, map;
        import std.format;
        import std.array : join, split, array;

        return childs
            .sort!"a.name < b.name".array
            .group!"a.name==b.name"
            .map!(p => p[1] > 1 ? format!"%s[%d]"(p[0].name, p[1]) : p[0].countChilds ? format!"%s(%d)"(p[0].name, p[0].countChilds) : p[0].name)
            .join("\n");
    }

    override Maybe!string order(string) {
        return None!string;
    }

    override string assign(string) {
        return "Cannot assign to World.";
    }
}
