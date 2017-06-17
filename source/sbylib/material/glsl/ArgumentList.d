module sbylib.material.glsl.ArgumentList;

import sbylib.material.glsl.Argument;
import sbylib.material.glsl.Function;
import sbylib.material.glsl.Token;

import std.algorithm;
import std.range;

class ArgumentList {
    Argument[] arguments;

    this() {}

    this(ref Token[] tokens) {
        while (tokens[0].str != ")") {
            this.arguments ~= new Argument(tokens);
            if (tokens[0].str == ",") {
                expect(tokens, [","]);
            }
        }
        expect(tokens, [")"]);
    }

    string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---ArgumentList\n";
        foreach (i, arg; this.arguments) {
            code ~= arg.graph(isEnd ~ (i == this.arguments.length-1));
        }
        return code;
    }

    string getCode() {
        return arguments.map!(arg => arg.getCode()).join(", ");
    }
}

