module sbylib.material.glsl.Sharp;

import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;

import std.format;

class Sharp : Statement {
    string type;
    string value;

    this() {}

    this(ref Token[] tokens) {
        assert(tokens[0].str == "#");
        this.type = tokens[1].str;
        this.value = tokens[2].str;
        tokens = tokens[3..$];
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---Sharp\n";
        code ~= indent(isEnd) ~ "|---" ~ this.type ~ "\n";
        code ~= indent(isEnd) ~ "|---" ~ this.value ~ "\n";
        return code;
    }

    override string getCode() {
        return format!"#%s %s"(this.type, this.value);
    }
}

