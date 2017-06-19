module sbylib.material.glsl.BlockDeclare;

import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.VariableDeclare;
import sbylib.material.glsl.Function;
import sbylib.material.glsl.BlockType;

import std.algorithm;
import std.conv;
import std.range;
import std.format;

class BlockDeclare : Statement {
    BlockType type;
    string id;
    VariableDeclare[] variables;

    this(string str) {
        auto tokens = tokenize(str);
        this(tokens);
    }

    this(ref Token[] tokens) {
        this.type = find!(BlockType, getBlockTypeCode)(tokens);
        this.id = convert(tokens);
        expect(tokens, ["{"]);
        while (tokens[0].str != "}") {
            this.variables ~= new VariableDeclare(tokens);
        }
        expect(tokens, ["}"]);
        expect(tokens, [";"]);
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---Block\n";
        code ~= indent(isEnd) ~ "|---" ~ to!string(this.type);
        foreach (i,v; this.variables) {
            code ~= "\n" ~ v.graph(isEnd ~ (i == this.variables.length-1));
        }
        return code;
    }

    override string getCode() {
        string code = format!"%s %s {\n"(getBlockTypeCode(this.type), this.id);
        foreach (v; variables) {
            code ~= format!"  %s\n"(v.getCode());
        }
        code ~= "};";
        return code;
    }
}
