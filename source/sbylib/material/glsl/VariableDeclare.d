module sbylib.material.glsl.VariableDeclare;

import sbylib.material.glsl.AttributeList;
import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;

import std.conv, std.format;

class VariableDeclare : Statement {
    AttributeList attributes;
    string type;
    string id;
    string assignedValue;

    this(string str) {
        auto tokens = tokenize(str);
        this(tokens);
    }

    this(ref Token[] tokens) {
        this.attributes = new AttributeList(tokens);
        this.type = convert(tokens);
        this.id = convert(tokens);
        if (tokens.length > 0 && tokens[0].str == "=") {
            expect(tokens, "=");
            while (tokens[0].str != ";") {
                this.assignedValue ~= convert(tokens);
            }
        }
        expect(tokens, ";");
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---Varible\n";
        code ~= indent(isEnd) ~ "|---" ~ this.type ~ "\n";
        code ~= attributes.graph(isEnd ~ true) ~ "\n";
        return code;
    }

    override string getCode() {
        string code;
        code ~= attributes.getCode();
        if (code.length > 0) {
            code ~= " ";
        }
        code ~= format!"%s %s"(type, id);
        if (assignedValue) {
            code ~= format!" = %s;"(assignedValue);
        } else {
            code ~= ";";
        }
        return code;
    }
}
