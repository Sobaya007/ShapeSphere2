module game.console.selections.RootSelection;

import sbylib;
import game.console.selections.Selectable;
import game.console.selections.WorldSelection;
import game.console.selections.SaveSelection;
import game.console.selections.QuitSelection;
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
            cast(Selectable)new WorldSelection(this, "world3d", Game.getWorld3D()),
            cast(Selectable)new WorldSelection(this, "world2d", Game.getWorld2D()),
            cast(Selectable)new SaveSelection(this),
            cast(Selectable)new QuitSelection(this)
        ];
    }

    override string assign(string) {
        return "Cannot assign to root.";
    }
}
