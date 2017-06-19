module sbylib.material.glsl.Require;

import sbylib.material.glsl.AttributeDemand;
import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Space;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;
import sbylib.material.glsl.VariableDeclare;
import sbylib.material.glsl.UniformDemand;

import std.format;
import std.algorithm;
import std.array;
import std.range;

class Require : Statement {
    AttributeDemand attr;
    Space space;
    VariableDeclare variable;

    this(string str) {
        auto tokens = tokenize(str);
        this(tokens);
    }

    this(ref Token[] tokens) {
        expect(tokens, ["require"]);
        this.attr = find!(AttributeDemand, getAttributeDemandName)(tokens);
        if (tokens[0].str == "in") {
            expect(tokens, ["in"]);
            this.space = find!(Space, getSpaceName)(tokens);
        }
        expect(tokens, ["as"]);
        this.variable = new VariableDeclare(tokens);
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---Require\n";
        code ~= indent(isEnd) ~ "|---" ~ getAttributeDemandName(this.attr) ~ "\n";
        code ~= indent(isEnd) ~ "|---" ~ getSpaceName(this.space) ~ "\n";
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

    VariableDeclare getVertexIn() {
        return new VariableDeclare(format!("in %s %s;")(getAttributeDemandType(attr), getAttributeDemandName(attr)));
    }

    string getVertexBodyCode() {
        return format!("%s = %s;")(
                getAttributeDemandName(attr),
                (this.space.getUniformDemands().map!(a => getUniformDemandCode(a)).array ~ getAttributeDemandName(attr)).join(" * "));
    }
}
