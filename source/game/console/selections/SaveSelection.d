module game.console.selections.SaveSelection;

import sbylib;
import game.console.selections.Selectable;
import game.console.selections.WorldSelection;
import game.Game;

class SaveSelection : Selectable {

    mixin ImplCountChild!(false);

    private Selectable mParent;

    this(Selectable parent) {
        this.mParent = parent;
    }

    override string name() {
        return "save";
    }

    override Selectable parent() {
        return mParent;
    }

    override Selectable[] childs() {
        return null;
    }

    override string getInfo() {
        Game.getMap().save();
        return "Saved.";
    }

    override string assign(string) {
        return "Cannot assign to <command>.";
    }
}
