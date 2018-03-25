module game.console.selections.WorldSelection;
import sbylib;
import game.console.selections.Selectable;
import game.console.selections.EntitySelection;

class WorldSelection : Selectable {

    private Selectable mParent;
    private string mName;
    private World world;

    this(Selectable parent, string name, World world) {
        this.mParent = parent;
        this.mName = name;
        this.world = world;
    }

    mixin ImplCountChild!(true);

    override string name() {
        return mName;
    }

    override Selectable parent() {
        return mParent;
    }

    override Selectable[] childs() {
        import std.algorithm : filter, map;
        import std.array : array;

        return [cast(Selectable)new EntitySelection(this, world.getCamera)]
        ~ world.getEntities.filter!(e => e.getParent.isNone).map!(e => cast(Selectable)new EntitySelection(this, e)).array;
    }

    override Maybe!string order(string) {
        return None!string;
    }

    override string assign(string) {
        return "Cannot assign to World.";
    }
}
