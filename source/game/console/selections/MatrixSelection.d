module game.console.selections.MatrixSelection;

import sbylib;
import game.console.selections.Selectable;

class MatrixSelection : Selectable {
    private ChangeObserved!mat3* mat;
    this(ref ChangeObserved!mat3 mat) {this.mat = &mat;}

    override string[] childNames() {
        return [];
    }

    override Selectable[] findChild(string name) {
        return null;
    }

    override string getInfo() {
        return mat.toString;
    }

    override Maybe!string order(string) {
        return None!string;
    }

    override string assign(string val) {
        return "Cannot assign to <matrix>";
    }
}

