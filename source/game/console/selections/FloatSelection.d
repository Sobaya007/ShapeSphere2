module game.console.selections.FloatSelection;

import sbylib;
import game.console.selections.Selectable;

class FloatSelection(bool CanAssign) : Selectable {

    static if (CanAssign) {
        alias T = ChangeObserved!(float*);
    } else {
        alias T = float;
    }

    private Selectable mParent;
    private string mName;
    private T elem;

    this(Selectable parent, string name, T elem) {
        this.mParent = parent;
        this.mName = name;
        this.elem = elem;
    }

    mixin ImplCountChild!(false);

    override string name() {
        return mName;
    }

    override Selectable parent() {
        return mParent;
    }

    override Selectable[] childs() {
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
