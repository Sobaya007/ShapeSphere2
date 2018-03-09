module sbylib.material.glsl.RequireShader;

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

class RequireShader : Statement {

    string id;

    this(string str) {
        auto tokens = tokenize(str);
        this(tokens);
    }

    this(ref Token[] tokens) {
        expect(tokens, "require");
        expect(tokens, "Shader");
        this.id = convert(tokens);
        expect(tokens, ";");
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---RequireAttribute\n";
        code ~= indent(isEnd) ~ "|---" ~ id ~ "\n";
        return code;
    }

    override string getCode() {
        return "";
    }
}
