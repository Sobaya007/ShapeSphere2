module sbylib.material.glsl.VariableDeclare;

import sbylib.material.glsl.Attribute;
import sbylib.material.glsl.Constants;
import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;

import std.conv, std.format;

class VariableDeclare : Statement {
    AttributeList attributes;
    Type type;
    string id;
    string assignedValue;

    this(ref Token[] tokens) {
        this.attributes = new AttributeList(tokens);
        this.type = convert!Type(tokens);
        this.id = convert(tokens);
        if (tokens[0].str == "=") {
            expect(tokens, ["="]);
            this.assignedValue = convert(tokens);
        }
        expect(tokens, [";"]);
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---Varible\n";
        code ~= indent(isEnd) ~ "|---" ~ to!string(this.type) ~ "\n";
        code ~= attributes.graph(isEnd ~ true) ~ "\n";
        return code;
    }

    override string getCode() {
        string code;
        code ~= attributes.getCode();
        if (code.length > 0) {
            code ~= " ";
        }
        code ~= format!"%s %s"(cast(string)type, id);
        if (assignedValue) {
            code ~= format!" = %s;"(assignedValue);
        } else {
            code ~= ";";
        }
        return code;
    }
}
