module game.console.selections.RootSelection;

import sbylib;
import game.console.selections.Selectable;
import game.console.selections.WorldSelection;
import game.Game;

class RootSelection : Selectable {
    override string[] childNames() {
        return ["world3d", "world2d", "save", "quit"];
    }

    override Selectable[] findChild(string name) {
        if (name == "world3d") return [new WorldSelection(Game.getWorld3D)];
        if (name == "world2d") return [new WorldSelection(Game.getWorld2D)];
        return null;
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

    override string getInfo() {
        return null;
    }

    override string assign(string) {
        return "Cannot assign to root.";
    }
}
