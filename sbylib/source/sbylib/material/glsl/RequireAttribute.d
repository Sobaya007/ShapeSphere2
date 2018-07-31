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
    bool isInFragment = true;

    this(AttributeDemand attr, Space space, VariableDeclare variable) {
        this.attr = attr;
        this.space = space;
        this.variable = variable;
    }

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
        return isInFragment ? this.getFragmentIn() : "";
    }

    // this function's return type must be 'Statement' not 'VariableDeclare' because of D's bug that A[] ~= B[] makes Segmentation fault in which A is B's super class
    Statement getVertexIn() {
        return new VariableDeclare(format!("in %s %s;")(getAttributeDemandType(attr), getAttributeDemandName(attr)));
    }

    Statement getVertexOut() {
        return new VariableDeclare(format!("out %s %s;")(variable.type, variable.id));
    }

    Statement getGeometryIn() {
        // geometry shader's input variables must be array
        return new VariableDeclare(format!("in %s %s[];")(getAttributeDemandType(attr), getAttributeDemandName(attr)));
    }

    string getFragmentIn() {
        return format!"%sin %s %s;"(this.variable.attributes.getCode(), variable.type, variable.id);
    }

    string getVertexBodyCode() {
        auto uniforms = this.space.getUniformDemands().map!(a => getUniformDemandName(a)).array;
        auto rightHand = getAttributeDemandBodyExpression(attr);
        rightHand = (uniforms ~ rightHand).join(" * ");
        rightHand = convertCode(rightHand, variable.type);
        return format!("%s = %s;")(variable.id, rightHand);
    }

    string getGeometryBodyCode() {
        auto uniforms = this.space.getUniformDemands().map!(a => getUniformDemandName(a)).array;
        auto rightHand = getAttributeDemandBodyExpression!(s => "g"~s~"[i]")(attr);
        rightHand = (uniforms ~ rightHand).join(" * ");
        rightHand = convertCode(rightHand, variable.type);
        return format!("%s = %s;")(variable.id, rightHand);
    }

    private string convertCode(string expr, string type) {
        final switch (type) {
        case "vec2":
            return format!"(%s).xy"(expr);
        case "vec3":
            return format!"(%s).xyz"(expr);
        case "vec4":
            return expr;
        }
    }

    void replaceID(string delegate(string) replace) {
        this.variable.replaceID(replace);
    }
}
