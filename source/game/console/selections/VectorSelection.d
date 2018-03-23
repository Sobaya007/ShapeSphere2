module game.console.selections.VectorSelection;

import sbylib;
import game.console.selections.Selectable;
import game.console.selections.FloatSelection;

class VectorSelection : Selectable {
    private ChangeObserved!vec3* vec;
    this(ref ChangeObserved!vec3 vec) {this.vec = &vec;}

    override string[] childNames() {
        return ["x", "y", "z"];
    }

    override Selectable[] findChild(string name) {
        if (name == "x") return [new FloatSelection(this.vec.x)];
        if (name == "y") return [new FloatSelection(this.vec.y)];
        if (name == "z") return [new FloatSelection(this.vec.z)];
        return null;
    }

    override string getInfo() {
        return vec.toString;
    }

    override Maybe!string order(string) {
        return None!string;
    }

    override string assign(string val) {
        import std.string : strip, startsWith, endsWith;
        import std.array : split;
        import std.conv;
        import std.format;

        val = val.strip;
        if (!val.startsWith("(")) return "<vector> must start with '('";
        if (!val.endsWith(")")) return "<vector> must end with ')'";
        auto values = val[1..$-1].split(",").to!(float[]);
        scope (failure) return format!"Cannot interpret '%s' as vector"(val);
        if (values.length != 3) return format!"<vector> must have just 3 elements. not %d."(values.length);
        *vec = vec3(values);
        return getInfo();
    }
}

