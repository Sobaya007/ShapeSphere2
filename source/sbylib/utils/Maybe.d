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

    auto opDispatch(string fn, Args...)(lazy Args args) {
        static if(args.length == 0) {
            alias F = typeof(mixin("value." ~ fn));
            static if(isCallable!F)
                enum MethodCall = "value." ~ fn ~ "()";
            else // property access
                enum MethodCall = "value." ~ fn;
        } else {
            enum MethodCall = "value." ~ fn ~ "(args)";
        }
        alias R = typeof(mixin(MethodCall));
        static if(is(R == void)) {
            if (this.isNone) return;
            mixin(MethodCall ~ ';');
        } else {
            if (this.isNone) return None!R;
            return Just(mixin(MethodCall));
        }
    }

    T get() in {
        assert(!_none, "this is none");
    } body {
        return this.value;
    }

    Maybe!T take() {
        if (this.isJust) {
            this._none = true;
            return Just(value);
        }
        return None!T;
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

T getOrElse(T)(Maybe!T m, T defaultValue) {
    if (m.isNone) return defaultValue;
    return m.get;
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

auto match(alias funJust, alias funNone, T)(Maybe!T m) {
    if (m.isJust) {
        return funJust(m.get);
    } else {
        return funNone();
    }
}

Maybe!T Just(T)(T v) in {
    static if (is(T == class) || is(T == function) || is(T == delegate) || is(T == interface) || isArray!(T)) {
        assert(v !is null);
    }
} body {
    return Maybe!T(v);
}

Maybe!T None(T)() {
    return Maybe!T(true);
}

auto wrap(T)(T value) {

    static if (isPointer!T) {
        if (value is null) {
            return None!(PointerTarget!T);
        } else {
            return Just(*value);
        }
    } else static if (is(typeof({bool po = value is null;}))) {
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
