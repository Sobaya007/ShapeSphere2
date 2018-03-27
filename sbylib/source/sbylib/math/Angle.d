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

    Degree opBinary(string op)(float v) @nogc {
        return Degree(mixin("deg " ~ op ~ " v"));
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

    Radian opBinary(string op)(float v) @nogc {
        return Radian(mixin("rad " ~ op ~ " v"));
    }

    alias rad this;
}

Degree deg(float d) @nogc {
    return Degree(d);
}

Radian rad(float r) @nogc {
    return Radian(r);
}

Degree deg(Radian r) @nogc {
    return Degree(r);
}

Radian rad(Degree d) @nogc {
    return Radian(d);
}
