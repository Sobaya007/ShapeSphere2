module sbylib.material.glsl.Function;

import sbylib.material.glsl.Token;
import std.traits;
import std.format;
import std.algorithm;
import std.array;

bool isConvertible(T)(Token[] tokens) {
    auto t = tokens[0];
    foreach (mem; [EnumMembers!T]) {
        if (mem == t.str)
            return true;
    }
    return false;
}

T convert(T)(string str) if (is(T == enum)) {
    foreach (mem; [EnumMembers!T]) {
        if (mem == str)
            return mem;
    }
    assert(false, format!"%s is not %s"(str, T.stringof));
}

T convert(T)(ref Token[] tokens) if (is(T == enum)) {
    auto t = tokens[0];
    tokens = tokens[1..$];
    return convert!T(t.str);
}

string convert(ref Token[] tokens) {
    auto t = tokens[0];
    tokens = tokens[1..$];
    return t.str;
}

void expect(ref Token[] tokens, string[] expected) {
    auto token = tokens[0];
    tokens = tokens[1..$];
    auto strs = expected.map!(a => format!"'%s'"(a)).array;
    assert(expected.any!(a => a == token.str), format!"Error[%d, %d]:%s was expected, not '%s'"(token.line, token.column, strs.join(" or "), token.str));
}


string indent(bool[] isEnd) {
    return isEnd.map!(e => e ? "    " : "|   ").array.join;
}
