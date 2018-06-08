module sbylib.material.glsl.LayoutDeclare;

import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;

import std.conv, std.algorithm, std.range, std.format;

class LayoutDeclare : Statement {
    string arguments;
    string type;

    this(ref Token[] tokens) {
        expect(tokens, "layout");
        expect(tokens, "(");
        while (!tokens.empty && tokens.front.str != ")") {
            arguments ~= tokens.front.str;
            tokens = tokens[1..$];
        }
        expect(tokens, ")");
        type = convert(tokens);
        expect(tokens, ";");
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---Layout\n";
        code ~= indent(isEnd) ~ "|---" ~ this.arguments ~ "\n";
        code ~= indent(isEnd) ~ "|---" ~ this.type ~ "\n";
        return code;
    }

    override string getCode() {
        return format!"layout(%s) %s;"(this.arguments, this.type);
    }
}
