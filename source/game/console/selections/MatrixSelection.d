module game.console.selections.MatrixSelection;

import sbylib;
import game.console.selections.Selectable;
import game.console.selections.VectorSelection;

class MatrixSelection : Selectable {
    private ChangeObserved!mat3* mat;
    this(ref ChangeObserved!mat3 mat) {this.mat = &mat;}

    override string[] childNames() {
        import std.algorithm : cartesianProduct, map;
        import std.range : iota;
        import std.array : array, join;
        import std.format;

        return cartesianProduct(["column", "row"], 3.iota.map!(i => format!"[%d]"(i)).array)
            .map!"a[0]~a[1]".array;
    }

    override Selectable[] findChild(string name) {
        import std.string : startsWith;
        import std.regex;
        import std.conv;
        auto r = ctRegex!"[\\d]";
        auto m = name.match(r);
        if (!m.hit) return null;

        auto index = m.hit.to!int;
        scope (failure) return null;

        if(index < 0) return null;
        if (index >= 3) return null;

        if (name.startsWith("column")) {
            return [new VectorSelection!false(mat.column[index])];
        } else if (name.startsWith("row")) {
            return [new VectorSelection!false(mat.row[index])];
        }
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

