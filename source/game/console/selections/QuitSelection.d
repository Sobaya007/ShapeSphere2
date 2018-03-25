module game.console.selections.QuitSelection;

import sbylib;
import game.console.selections.Selectable;
import game.console.selections.WorldSelection;
import game.Game;

class QuitSelection : Selectable {

    mixin ImplCountChild!(false);

    private Selectable mParent;

    this(Selectable parent) {
        this.mParent = parent;
    }

    override string name() {
        return "quit";
    }

    override Selectable parent() {
        return mParent;
    }

    override Selectable[] childs() {
        return null;
    }

    override string getInfo() {
        Game.getCommandManager().save();
        Core().end();
        return "Quit.";
    }

    override string assign(string) {
        return "Cannot assign to <command>.";
    }
}
