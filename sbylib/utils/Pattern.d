module sbylib.utils.Pattern;

import std.variant;
import sbylib.utils.Maybe;

auto Pattern(Type)(Type value) {
    return PD!(Type)(value);
}

private struct PD(A) {
    A a;
    alias a this;
}

private struct P(A, B) {
    Maybe!(A) a;
    Maybe!(B) b;

    invariant {
        assert(a.isJust && b.isNone || a.isNone && b.isJust);
    }

    static auto left(A a) {
        P!(A, B) p;
        p.a = Just(a);
        return p;
    }

    static auto right(B b) {
        P!(A, B) p;
        p.b = Just(b);
        return p;
    }

    B get() {
        return this.b.get();
    }
}

auto match(alias pred, Type, Result)(PD!(Type) value, lazy Result result) {
    if (pred(value)) return P!(Type, Result).right(result);
    return P!(Type, Result).left(value);
}

auto match(alias pred, Type, Result)(P!(Type, Result) alg, lazy Result result) {
    if (alg.b.isJust) return alg;
    if (pred(alg.a.get())) return P!(Type, Result).right(result);
    return alg;
}

auto other(Type, Result)(P!(Type, Result) alg, lazy Result result) {
    if (alg.b.isJust) return alg.b.get();
    return result;
}
