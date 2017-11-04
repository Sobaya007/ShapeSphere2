module sbylib.utils.Maybe;

struct Maybe(T) {
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
        assert(!_none);
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

auto fmap(alias fun, T)(Maybe!T m) {
    import std.traits;
    if (m.isNone) return None!(ReturnType!fun);
    return Just(fun(m.get));
}

void apply(alias fun, T)(Maybe!T m) {
    if (m.isJust) {
        fun(m.get);
    }
}

Maybe!T Just(T)(T v) {
    return Maybe!T(v);
}

Maybe!T None(T)() {
    return Maybe!T(true);
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