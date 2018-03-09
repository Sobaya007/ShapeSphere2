module sbylib.material.glsl.RequireUniform;

import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;
import sbylib.material.glsl.UniformDemand;

import std.algorithm;
import std.range;

class RequireUniform : Statement {

    UniformDemand uni;

    this(string str) {
        auto tokens = tokenize(str);
        this(tokens);
    }

    this(ref Token[] tokens) {
        expect(tokens, "require");
        this.uni = convert!(UniformDemand, getUniformDemandName)(tokens);
        expect(tokens, ";");
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---RequireUniform\n";
        code ~= indent(isEnd) ~ "|---" ~ getUniformDemandName(this.uni) ~ "\n";
        return code;
    }

    override string getCode() {
        return getUniformDemandDeclare(uni).map!(a => a.getCode()).join("\n");
    }
}
