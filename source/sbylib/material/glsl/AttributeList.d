module sbylib.material.glsl.AttributeList;

import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;
import sbylib.material.glsl.Attribute;
import std.conv;
import std.algorithm;
import std.range;

class AttributeList {
    Attribute[] attributes;

    this() {}

    this(ref Token[] tokens) {
        while (isConvertible!(Attribute, getAttributeCode)(tokens)) {
            this.attributes ~= find!(Attribute, getAttributeCode)(tokens);
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
        return attributes.map!(a => getAttributeCode(a)).join(" ");
    }

    bool has(Attribute attr) {
        return this.attributes.any!(a => a == attr);
    }
}

