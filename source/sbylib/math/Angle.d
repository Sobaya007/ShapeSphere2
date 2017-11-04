module sbylib.math.Angle;

import std.math;

struct Degree {
    float deg;

    private this(float deg) @nogc {
        this.deg = deg;
    }

    this(Radian rad) @nogc {
        this.deg = rad * 180 / PI;
    }

    Degree opUnary(string op)() @nogc {
        return Degree(mixin(op ~ "deg"));
    }

    alias deg this;
}

struct Radian {
    float rad;

    private this(float rad) @nogc {
        this.rad = rad;
    }

    this(Degree deg) @nogc {
        this.rad = deg * PI / 180;
    }

    Radian opUnary(string op)() @nogc {
        return Radian(mixin(op ~ "rad"));
    }

    alias rad this;
}

Degree deg(float d) @nogc {
    return Degree(d);
}

Radian rad(float r) @nogc {
    return Radian(r);
}
