module sbylib.material.glsl.RequireAttribute;

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

class RequireAttribute : Statement {
    AttributeDemand attr;
    Space space;
    VariableDeclare variable;

    this(string str) {
        auto tokens = tokenize(str);
        this(tokens);
    }

    this(ref Token[] tokens) {
        expect(tokens, "require");
        this.attr = convert!(AttributeDemand, getAttributeDemandKeyWord)(tokens);
        if (tokens[0].str == "in") {
            expect(tokens, "in");
            this.space = convert!(Space, getSpaceName)(tokens);
        }
        expect(tokens, "as");
        this.variable = new VariableDeclare(tokens);
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---RequireAttribute\n";
        code ~= indent(isEnd) ~ "|---" ~ getAttributeDemandName(this.attr) ~ "\n";
        code ~= indent(isEnd) ~ "|---" ~ getSpaceName(this.space) ~ "\n";
        code ~= this.variable.graph(isEnd ~ true);
        return code;
    }

    override string getCode() {
        return this.getFragmentIn();
    }

    Statement getVertexIn() {
        return new VariableDeclare(format!("in %s %s;")(getAttributeDemandType(attr), getAttributeDemandName(attr)));
    }

    Statement getVertexOut() {
        return new VariableDeclare(format!("out %s %s;")(getAttributeDemandType(attr), variable.id));
    }

    string getVertexBodyCode() {
        auto rightHand = (this.space.getUniformDemands().map!(a => getUniformDemandName(a)).array ~ getAttributeDemandBodyExpression(attr)).join(" * ");
        final switch (variable.type) {
        case "vec2":
            rightHand = format!"(%s).xy"(rightHand);
            break;
        case "vec3":
            rightHand = format!"(%s).xyz"(rightHand);
            break;
        case "vec4":
            break;
        }
        return format!("%s = %s;")(variable.id, rightHand);
    }

    string getFragmentIn() {
        return format!"%sin %s %s;"(this.variable.attributes.getCode(), getAttributeDemandType(attr), variable.id);
    }

    void replaceID(string delegate(string) replace) {
        this.variable.replaceID(replace);
    }
}
