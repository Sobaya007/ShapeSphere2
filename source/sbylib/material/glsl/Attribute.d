module sbylib.material.glsl.Attribute;

import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;
import std.conv;
import std.algorithm;
import std.range;

enum Attribute {
    In = "in",
    Out = "out",
    Uniform = "uniform",
    Const = "const",
    Flat = "flat"
}

class AttributeList {
    Attribute[] attributes;

    this() {}

    this(ref Token[] tokens) {
        while (isConvertible!Attribute(tokens)) {
            this.attributes ~= convert!Attribute(tokens);
        }
    }

    string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---AttributeList";
        foreach (i, attr; this.attributes) {
            code ~= "\n" ~ indent(isEnd) ~ "|---" ~ to!string(attr);
        }
        return code;
    }

    string getCode() {
        return attributes.map!(a => cast(string)a).join(" ");
    }

    bool has(Attribute attr) {
        return this.attributes.any!(a => a == attr);
    }
}

