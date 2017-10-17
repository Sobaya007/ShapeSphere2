module sbylib.utils.Maybe;

struct Maybe(T) {
    private T value;
    private bool _none;

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

Maybe!T Just(T)(T v) {
    return Maybe!T(v);
}

Maybe!T None(T)() {
    return Maybe!T(true);
}

unittest {
    auto po = Just(3);

    assert(po.just == 3);
    assert(!po.none);
}
