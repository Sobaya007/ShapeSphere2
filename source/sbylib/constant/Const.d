module sbylib.constant.Const;

import std.json;
import std.traits;
import sbylib.math.Vector;

interface Const {
    JSONValue getJSON();
    void setValue(Const);
}

class ConstTemp(T) : Const {
    private T value;
    private string name;

    this(string name, T value) {
        this.name = name;
        this.value = value;
    }

    override JSONValue getJSON() {
        static if (isInstanceOf!(Vector, T)) {
            return JSONValue(this.value.array[]);
        } else {
            return JSONValue(this.value);
        }
    }

    override void setValue(Const target) {
        if (typeof(this) t = cast(typeof(this))target) {
            this.value = t.value;
            return;
        }
        assert(false);
    }

    T get() {
        return this.value;
    }

    override string toString() {
        import std.conv;
        return to!string(this.value);
    }

    alias get this;
}
