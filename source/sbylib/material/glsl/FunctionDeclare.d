module sbylib.material.glsl.FunctionDeclare;

import sbylib.material.glsl.Attribute;
import sbylib.material.glsl.ArgumentList;
import sbylib.material.glsl.Constants;
import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;

import std.conv, std.algorithm, std.range, std.format;

class FunctionDeclare : Statement {
    Type returnType;
    string id;
    ArgumentList arguments;
    string content;

    this() {}

    this(ref Token[] tokens) {
        this.returnType = convert!Type(tokens);
        this.id = convert(tokens);
        expect(tokens, ["("]);
        this.arguments = new ArgumentList(tokens);
        expect(tokens, ["{"]);
        this.content = convert(tokens);
        expect(tokens, ["}"]);
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---Function\n";
        code ~= indent(isEnd) ~ "|---" ~ to!string(this.returnType) ~ "\n";
        code ~= this.arguments.graph(isEnd ~ true);
        return code;
    }

    override string getCode() {
        return format!"%s %s(%s) {%s}"(cast(string)returnType, id, arguments.getCode(), content);
    }
}
