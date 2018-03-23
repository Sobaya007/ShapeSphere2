module game.console.selections.FloatSelection;

import sbylib;
import game.console.selections.Selectable;

class FloatSelection : Selectable {
    private ChangeObserved!(float*) elem;
    this(ChangeObserved!(float*) elem) {this.elem = elem;}

    override string[] childNames() {
        return null;
    }

    override Selectable[] findChild(string name) {
        return null;
    }

    override string getInfo() {
        import std.conv;
        return elem.get.to!string;
    }

    override Maybe!string order(string) {
        return None!string;
    }

    override string assign(string val) {
        import std.conv;
        import std.string : strip;
        import std.format;

        auto value = val.strip.to!float;
        scope (failure) return format!"Cannot interpret '%s' as <float>"(val.strip);
        elem = value;
        return getInfo();
    }
}
