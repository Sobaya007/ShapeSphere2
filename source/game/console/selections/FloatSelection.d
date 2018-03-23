module game.console.selections.FloatSelection;

import sbylib;
import game.console.selections.Selectable;

class FloatSelection(bool CanAssign) : Selectable {

    static if (CanAssign) {
        alias T = ChangeObserved!(float*);
    } else {
        alias T = float;
    }

    private T elem;
    this(T elem) {this.elem = elem;}

    override string[] childNames() {
        return null;
    }

    override Selectable[] findChild(string name) {
        return null;
    }

    override string getInfo() {
        import std.conv;
        static if (CanAssign) {
            return elem.get.to!string;
        } else {
            return elem.to!string;
        }
    }

    override Maybe!string order(string) {
        return None!string;
    }

    override string assign(string val) {
        import std.conv;
        import std.string : strip;
        import std.format;

        static if (CanAssign) {
            auto value = val.strip.to!float;
            scope (failure) return format!"Cannot interpret '%s' as <float>"(val.strip);
            elem = value;
            return getInfo();
        } else {
            return "Cannot assign to this <float>";
        }
    }
}
