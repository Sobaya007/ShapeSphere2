module sbylib.material.glsl.Argument;

import sbylib.material.glsl.Attribute;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Constants;
import sbylib.material.glsl.Function;
import std.conv;
import std.format;

class Argument {
    AttributeList attributes;
    Type type;
    string id;

    this() {}

    this(ref Token[] tokens) {
        this.attributes = new AttributeList(tokens);
        this.type = convert!Type(tokens);
        this.id = convert(tokens);
    }

    string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---Argument\n";
        code ~= indent(isEnd) ~ "|---" ~ to!string(this.type) ~ "\n";
        code ~= this.attributes.graph(isEnd ~ true) ~ "\n";
        return code;
    }

    string getCode() {
        string code = attributes.getCode();
        if (code.length > 0) {
            code ~= " ";
        }
        code ~= format!"%s %s"(cast(string)type, id);
        return code;
    }
}
