module sbylib.material.glsl.Function;

import sbylib.material.glsl.Token;
import std.traits;
import std.format;
import std.algorithm;
import std.array;

bool isConvertible(T, alias conv)(Token[] tokens) if (is(T == enum)){
    if (tokens.length == 0) return false;
    auto t = tokens[0];
    return isConvertible!(T, conv)(t.str);
}

bool isConvertible(T, alias conv)(string str) if (is(T == enum)) {
    foreach (mem; [EnumMembers!T]) {
        if (conv(mem) == str)
            return true;
    }
    return false;
}

T find(T, alias conv)(ref Token[] tokens) if (is(T == enum)) {
    auto t = tokens[0];
    tokens = tokens[1..$];
    return find!(T, conv)(t.str);
}

T find(T, alias conv)(string str) if (is(T == enum)) {
    foreach (mem; [EnumMembers!T]) {
        if (conv(mem) == str)
            return mem;
    }
    assert(false, format!"%s is not %s"(str, T.stringof));
}

string convert(ref Token[] tokens) in {
    assert(tokens.length > 0);
} body{
    auto t = tokens[0];
    tokens = tokens[1..$];
    return t.str;
}

void expect(ref Token[] tokens, string[] expected) {
    auto strs = expected.map!(a => format!"'%s'"(a)).array;
    assert(tokens.length > 0, format!"%s was expected, but no tokens found here."(strs.join(" or ")));
    auto token = tokens[0];
    tokens = tokens[1..$];
    assert(expected.any!(a => a == token.str), format!"Error[%d, %d]:%s was expected, not '%s'"(token.line, token.column, strs.join(" or "), token.str));
}

string indent(bool[] isEnd) {
    return isEnd.map!(e => e ? "    " : "|   ").array.join;
}

mixin template constructor() {
    this (string str) {
        auto tokens = tokenize(str);
        this(tokens);
    }
}
