module game.console.selections.RootSelection;

import sbylib;
import game.console.selections.Selectable;
import game.console.selections.WorldSelection;
import game.Game;

class RootSelection : Selectable {

    mixin ImplCountChild!(true);

    override string name() {
        return null;
    }

    override Selectable parent() {
        return null;
    }

    override Selectable[] childs() {
        return [
            new WorldSelection(this, "world3d", Game.getWorld3D()),
            new WorldSelection(this, "world2d", Game.getWorld2D())
        ];
    }

    override Maybe!string order(string code) {
        if (code == "save") {
            Game.getMap().save();
            return Just("Saved.");
        }
        if (code == "quit") {
            Game.getCommandManager().save();
            Core().end();
        }
        return None!string;
    }

    override string assign(string) {
        return "Cannot assign to root.";
    }

    override int countChilds() {
        import std.algorithm : map, sum;

        return childs.map!(child => child.countChilds + 1).sum;
    }
}
