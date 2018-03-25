module game.console.selections.MatrixSelection;

import sbylib;
import game.console.selections.Selectable;
import game.console.selections.VectorSelection;

class MatrixSelection : Selectable {

    private Selectable mParent;
    private string mName;
    private ChangeObserved!mat3* mat;

    this(Selectable parent, string name, ref ChangeObserved!mat3 mat) {
        this.mParent = parent;
        this.mName = name;
        this.mat = &mat;
    }

    mixin ImplCountChild!(false);

    override string name() {
        return mName;
    }

    override Selectable parent() {
        return mParent;
    }

    override Selectable[] childs() {
        import std.algorithm : cartesianProduct, map;
        import std.range : iota;
        import std.array : array, join;
        import std.format;

        return 
                3.iota.map!(i => cast(Selectable)new VectorSelection!false(this, format!"column[%d]"(i), mat.column[i])).array
                ~ 3.iota.map!(i => cast(Selectable)new VectorSelection!false(this, format!"row[%d]"(i), mat.row[i])).array;
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

