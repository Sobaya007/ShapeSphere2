module game.console.selections.VectorSelection;

import sbylib;
import game.console.selections.Selectable;
import game.console.selections.FloatSelection;

class VectorSelection(bool CanAssign) : Selectable {
    private string mName;
    static if (CanAssign) {
        alias T = ChangeObserved!vec3;
        private T* vec;
        this(string name, ref T vec) {
            this.mName = name;
            this.vec = &vec;
        }
    } else {
        alias T = vec3;
        private T vec;
        this(string name, T vec) {
            this.mName = name;
            this.vec = vec;
        }
    }

    mixin ImplCountChild!(false);

    override string name() {
        return mName;
    }

    override Selectable[] childs() {
        return [
            new FloatSelection!(CanAssign)("x", this.vec.x),
            new FloatSelection!(CanAssign)("y", this.vec.y),
            new FloatSelection!(CanAssign)("z", this.vec.z),
        ];
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

        static if (CanAssign) {
            val = val.strip;
            if (!val.startsWith("(")) return "<vector> must start with '('";
            if (!val.endsWith(")")) return "<vector> must end with ')'";
            auto values = val[1..$-1].split(",").to!(float[]);
            scope (failure) return format!"Cannot interpret '%s' as vector"(val);
            if (values.length != 3) return format!"<vector> must have just 3 elements. not %d."(values.length);
            *vec = vec3(values);
            return getInfo();
        } else {
            return "Cannot assign to this <vector>";
        }
    }
}

