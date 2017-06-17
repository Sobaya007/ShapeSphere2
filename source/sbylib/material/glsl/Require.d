module sbylib.material.glsl.Require;

import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Constants;
import sbylib.material.glsl.Function;

import std.format;

class Require : Statement {
    VaryingDemand attr;
    Space space;
    Type type;
    string id;

    this(ref Token[] tokens) {
        expect(tokens, ["require"]);
        this.attr = convert!VaryingDemand(tokens);
        if (tokens[0].str == "in") {
            expect(tokens, ["in"]);
            this.space = convert!Space(tokens);
        }
        expect(tokens, ["as"]);
        this.type = convert!Type(tokens);
        this.id = convert(tokens);
        expect(tokens, [";"]);
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---Require\n";
        code ~= indent(isEnd) ~ "|---" ~ this.attr ~ "\n";
        code ~= indent(isEnd) ~ "|---" ~ this.space ~ "\n";
        code ~= indent(isEnd) ~ "|---" ~ this.type ~ "\n";
        return code;
    }

    override string getCode() {
        return format!"in %s %s;"(cast(string)this.type, this.id);
    }
}
