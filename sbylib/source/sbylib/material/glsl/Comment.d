module sbylib.material.glsl.Comment;

import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;
import std.format;

class Comment : Statement {

    string content;

    this(string str) {
        auto tokens = tokenize(str);
        this(tokens);
    }

    this(ref Token[] tokens) {
        expect(tokens, "//");
        this.content = convert(tokens);
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|--Comment\n";
        return code;
    }

    override string getCode() {
        string code = format!"//%s"(this.content);
        return code;
    }
}
