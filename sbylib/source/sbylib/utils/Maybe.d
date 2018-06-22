module sbylib.utils.Maybe;

import std.traits;
import std.format;
import std.conv;
import std.range;
import std.algorithm;


enum RefuseNullType(T) = isPointer!T || is(T == class) || is(T == interface) || is(T == function) || is(T == delegate);

struct Maybe(T) {

    alias Type = T;

    private T value;
    private bool _none = true;

    invariant {
        static if (RefuseNullType!(T)) {
            assert(_none || value !is null, T.stringof);
        }
    }

    private this(T value) in {
        static if (RefuseNullType!(T)) assert(value !is null);
    } body {
        this.value = value;
        this._none = false;
    }

    private this(bool none) {
        this._none = none;
    }

    auto opDispatch(string fn, Args...)(auto ref Args args) {
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
            return wrap(mixin(MethodCall));
        }
    }

    auto ref get() inout in {
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

    bool isJust() inout {
        return !_none;
    }

    bool isNone() inout {
        return _none;
    }

    int opCmp(S)(S value) in {
        assert(this.isJust);
    } body {
        return this.value > value;
    }

    Maybe!T opOpAssign(string op, S)(S value) {
        if (this.isNone) return this;
        mixin("this.value " ~ op ~ "= value;");
        return this;
    }

    string toString() {
        if (this.isJust) return format!"Just(%s)"(this.value.to!string);
        return "None";
    }

    alias empty = isNone;

    alias front = get;

    alias popFront = take;
}

auto fmap(alias fun, T)(Maybe!T m) {
    if (m.isJust) return Just(fun(m.get));
    return None!(typeof(return).Type);
}

T getOrElse(T)(Maybe!T m, T defaultValue) {
    if (m.empty) return defaultValue;
    return m.front;
}

T getOrError(T)(Maybe!T m, string errorMessage) {
    assert(!m.empty, errorMessage);
    return m.front;
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
    static if (is(typeof(v == null)) && !isArray!(T)) {
        assert(v != null);
    }
} body {
    return Maybe!T(v);
}

Maybe!T None(T)() {
    return Maybe!T();
}

auto wrapPointer(T)(T value) if (isPointer!T){
    if (value is null) {
        return None!(PointerTarget!T);
    } else {
        return Just(*value);
    }
}

auto wrapRange(T)(T value) if (isInputRange!T) {
    if (value.empty) {
        return None!(ElementType!T);
    } else {
        return Just(value.front);
    }
}

auto wrap(T)(T value) {
    static if (isPointer!T) {
        if (value is null) {
            return None!(T);
        } else {
            return Just(value);
        }
    } else static if (RefuseNullType!(T)) {
        if (value is null) {
            return None!T;
        } else {
            return Just(value);
        }
    } else static if (isInstanceOf!(Maybe, T)) {
        if (value.isNone) {
            return None!T;
        } else {
            return value;
        }
    } else {
        return Just(value);
    }
}

auto wrapCast(T, S)(S m) if (!isInstanceOf!(Maybe, S)) {
    return wrap(cast(T)m);
}

auto wrapCast(T, S)(Maybe!S m) {
    return m.fmapAnd!((S s) => wrap(cast(T)s));
}

auto wrapException(alias f)() {
    scope(failure) return None!(ReturnType!(f));
    return Just(f());
}

// InputRange!(Maybe!T) -> InputRange!T
auto catMaybe(Range)(Range r) if (isInputRange!Range && isInstanceOf!(Maybe, ElementType!Range)) {
    return r.filter!(m => m.isJust).map!(m => m.get);
}

auto at(T)(T[] array, long index) {
    if (index < 0) return None!T;
    if (index >= array.length) return None!T;
    return Just(array[index]);
}

auto at(T, S)(T[S] array, S key) {
    if (key !in array) return None!T;
    return Just(array[key]);
}

class MaybeEnvironment {
    import sbylib : Singleton;

    mixin Singleton;

    auto opDispatch(string fn, T, Args...)(Maybe!T value, Args args) {
        alias ReturnType = typeof(mixin("T.init."~fn~"(args)"));
        static if (is(ReturnType == void)) value.apply!(t => mixin("t."~fn~"(args)"));
        else return value.fmap!(t => mixin("t."~fn~"(args)"));
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

    intMaybe = Just(1);
    assert(intMaybe.isJust);
    assert(intMaybe > 0);
}

unittest {

}
