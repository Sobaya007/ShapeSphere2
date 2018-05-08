module sbylib.material.glsl.PrecisionDeclare;

import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Space;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;
import sbylib.material.glsl.RequireAttribute;
import sbylib.material.glsl.UniformDemand;

import std.format;
import std.algorithm;
import std.range;

enum Precision {
    Low,
    Medium,
    High
}

string getPrecisionCode(Precision p) {
    final switch (p) {
        case Precision.Low:
            return "lowp";
        case Precision.Medium:
            return "mediump";
        case Precision.High:
            return "highp";
    }
}

class PrecisionDeclare : Statement {
    Precision precision;
    string type;

    this(string str) {
        auto tokens = tokenize(str);
        this(tokens);
    }

    this(ref Token[] tokens) {
        expect(tokens, "precision");
        this.precision = convert!(Precision, getPrecisionCode)(tokens);
        this.type = convert(tokens);
        expect(tokens, ";");
    }

    override string graph(bool[] isEnd) {
        import std.conv : to;

        string code = indent(isEnd[0..$-1]) ~ "|---Precision\n";
        code ~= indent(isEnd) ~ "|---" ~ this.precision.to!string ~ "\n";
        code ~= indent(isEnd) ~ "|---" ~ this.type ~ "\n";
        return code;
    }

    override string getCode() {
        return format!"precision %s %s;"(getPrecisionCode(this.precision), this.type);
    }
}
