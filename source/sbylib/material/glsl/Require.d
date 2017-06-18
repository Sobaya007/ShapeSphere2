module sbylib.material.glsl.Require;

import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Constants;
import sbylib.material.glsl.Function;
import sbylib.material.glsl.VariableDeclare;

import std.format;

class Require : Statement {
    VaryingDemand attr;
    Space space;
    VariableDeclare variable;

    this(ref Token[] tokens) {
        expect(tokens, ["require"]);
        this.attr = convert!VaryingDemand(tokens);
        if (tokens[0].str == "in") {
            expect(tokens, ["in"]);
            this.space = convert!Space(tokens);
        }
        expect(tokens, ["as"]);
        this.variable = new VariableDeclare(tokens);
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---Require\n";
        code ~= indent(isEnd) ~ "|---" ~ this.attr ~ "\n";
        code ~= indent(isEnd) ~ "|---" ~ this.space ~ "\n";
        code ~= this.variable.graph(isEnd ~ true);
        return code;
    }

    override string getCode() {
        string code;
        if (this.variable.attributes.attributes.length > 0) {
            code = format!"%s "(this.variable.attributes.getCode());
        }
        return format!"%sin %s %s;"(code, cast(string)this.variable.type, this.variable.id);
    }
}
