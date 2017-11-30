module sbylib.utils.Maybe;

import std.traits;

struct Maybe(T) {

    alias Type = T;

    private T value;
    private bool _none = true;

    private this(T value) {
        this.value = value;
        this._none = false;
    }

    private this(bool none) {
        this._none = none;
    }

    T get() in {
        assert(!_none, "this is none");
    } body {
        return this.value;
    }

    bool isJust() {
        return !_none;
    }

    bool isNone() {
        return _none;
    }
}

Maybe!S fmap(alias fun, T, S = ReturnType!fun)(Maybe!T m) {
    if (m.isNone) return None!S;
    return Just(fun(m.get));
}

Maybe!S fmapAnd(alias fun, T, S = ReturnType!fun.Type)(Maybe!T m) {
    if (m.isNone) return None!S;
    return fun(m.get);
}

void apply(alias fun, T)(Maybe!T m) {
    if (m.isJust) {
        fun(m.get);
    }
}

Maybe!T Just(T)(T v) in {
    static if (is(T == class) || is(T == function) || is(T == delegate) || isArray!(T)) {
        assert(v !is null);
    }
} body {
    return Maybe!T(v);
}

Maybe!T None(T)() {
    return Maybe!T(true);
}

Maybe!T wrap(T)(T value) {
    static if (__traits(compiles, "value is null")) {
        if (value is null) {
            return None!T;
        } else {
            return Just(value);
        }
    } else {
        return Just(value);
    }
}

unittest {
    auto po = Just(3);

    assert(po.get == 3);
    assert(!po.isNone);
}

unittest {
    class A{
        int x;
    }

    Maybe!int intMaybe;
    assert(intMaybe.isNone);

    Maybe!A aMaybe;
    assert(aMaybe.isNone);
}
