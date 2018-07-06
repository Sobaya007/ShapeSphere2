module sbylib.math.Rational;

import std.conv;
import std.bigint;
import std.traits;

struct Rational(T) if (__traits(isIntegral, T) || is(T == BigInt)) {

    T nume = 0; // numerator
    T deno = 1; // denominator

    this(T nume, T deno)
        in(deno != 0)
    {
        this.nume = nume;
        this.deno = deno;
        simplify;
    }

    U getValue(U = float) () if (__traits(isFloating, U)) {
        return cast(U)nome / cast(U)deno;
    }

    Rational opBinary(string op)(Rational rhs) if (op == "+") {
        return Rational(nume * rhs.deno + deno*rhs.nume, deno*rhs.deno).simplify;
    }

    Rational opBinary(string op)(Rational rhs) if (op == "-") {
        return Rational(nume * rhs.deno - deno*rhs.nume, deno*rhs.deno).simplify;
    }

    Rational opBinary(string op)(Rational rhs) if (op == "*") {
        return Rational(nume*rhs.nume, deno*rhs.deno).simplify;
    }

    Rational opBinary(string op)(Rational rhs) if (op == "/") {
        return Rational(nume*rhs.deno, deno*rhs.nume).simplify;
    }

    Rational opBinary(string op)(T rhs) if (op == "+" || op == "-" || op == "*" || op == "/") {
        mixin("return this" ~ op ~ "Rational!T(rhs, 1.to!T);");
    }

    Rational opBinary(string op, U)(U n) if (op == "^^" && __traits(isIntegral, U))
        in(n >= 0)
    {
        Rational r = this;
        Rational result = Rational!T(1.to!T, 1.to!T);
        while (n > 0) {
            if (n & 1) result = result*r;
            r = r*r;
            n >>= 1;
        }
        return result;
    }

    void opOpAssign(string op)(Rational rhs) if ((op == "+" || op == "-" || op == "*" || op == "/") && is(typeof(rhs) == Rational)) {
        mixin("this = this" ~ op ~ "rhs;");
    }

    void opOpAssign(string op)(T rhs) if (op == "+" || op == "-" || op == "*" || op == "/") {
        mixin("this" ~ op ~ "= Rational!T(rhs, 1.to!T);");
    }

    bool opEquals(U)(const Rational!U rhs) if (__traits(isIntegral, U) || is(U == BigInt)) { // == !=
        return this.nume*rhs.deno == this.deno*rhs.nume;
    }

    int opCmp(U)(const Rational!U rhs) if (__traits(isIntegral, U) || is(U == BigInt)){ // < <= > >=
        return sgn(this.nume*rhs.deno - this.deno*rhs.nume).to!int;
    }

    string toString() {
        return format("%d / %d", nume, deno);
    }

private:
    Rational simplify() { // reduce this
        if (nume == 0) {
            deno = 1;
        } else {
            T temp = gcd(abs(deno), abs(nume));
            deno /= temp;
            nume /= temp;
            nume *= sgn(deno);
            deno = abs(deno);
        }
        return this;
    }

    T sgn(T a) {
        return (a>0 ? 1 : a<0 ? -1 : 0).to!T;
    }

    T gcd(T a, T b)
        in(a>=0 && b>=0)
    {
        if (b == 0) {
            return a;
        } else {
            return gcd(b, a%b);
        }
    }
}
