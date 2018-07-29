module sbylib.character.ColoredString;

import sbylib.math.Vector;

struct ColoredChar {
    dchar c;
    vec4 color;
}

struct ColoredString {

    ColoredChar[] array;
    alias array this;

    this(ColoredChar[] array) {
        this.array = array;
    }

    this(string str, vec4 color) {
        import std.range : repeat, take;
        import std.array;
        this(str, color.repeat().take(str.length).array);
    }

    this(string str, vec4[] color)
        in(str.length == color.length)
    { 
        import std.algorithm : map;
        import std.range : zip;
        import std.array;
        this.array = zip(str, color).map!(t => ColoredChar(t[0], t[1])).array;
    }

    auto opBinary(string op)(char c)
        if (op == "~")
    {
        import std.conv : to;
        return this ~ c.to!string;
    }

    auto opBinary(string op)(string str)
        if (op == "~")
    {
        import std.range : repeat;
        import std.array : back, array;
        return ColoredString(this.str~str, this.colors~this.colors.back.repeat(str.length).array);
    }

    auto opBinaryRight(string op)(char c)
        if (op == "~")
    {
        import std.conv : to;
        return c.to!string ~ this;
    }

    auto opBinaryRight(string op)(string str)
        if (op == "~")
    {
        import std.range : repeat;
        import std.array : front, array;
        return ColoredString(str~this.str, this.colors.front.repeat(str.length).array~this.colors);
    }

    void opOpAssign(string op)(char c)
        if (op == "~")
    {
        import std.conv : to;
        this ~= c.to!string;
    }

    void opOpAssign(string op)(string str)
        if (op == "~")
    {
        import std.range : repeat;
        import std.array : back, array;
        this.array ~= ColoredString(str, this.colors.back.repeat(str.length).array);
    }

    string str() {
        import std.algorithm : map;
        import std.conv : to;
        return this.array.map!(c => c.c).to!string;
    }

    vec4[] colors() {
        import std.algorithm : map;
        import std.array : array;
        return this.array.map!(c => c.color).array;
    }
}

auto colored(string str, vec3 color) {
    return ColoredString(str, vec4(color, 1));
}

auto colored(string str, vec4 color) {
    return ColoredString(str, color);
}

auto RED(string str) {
    return str.colored(vec3(1,0,0));
}

auto BLACK(string str) {
    return str.colored(vec3(0));
}

auto WHITE(string str) {
    return str.colored(vec3(1));
}

auto graduation(string str, vec4 from, vec4 to) {
    auto colors = new vec4[str.length];
    foreach (i, ref c; colors) {
        colors[i] = from + (to - from) * i / colors.length;
    }
    return ColoredString(str, colors);
}
