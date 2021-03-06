module sbylib.material.glsl.FunctionDeclare;

import sbylib.material.glsl.Attribute;
import sbylib.material.glsl.ArgumentList;
import sbylib.material.glsl.Statement;
import sbylib.material.glsl.Token;
import sbylib.material.glsl.Function;

import std.conv, std.algorithm, std.range, std.format;

class FunctionDeclare : Statement {
    string returnType;
    string id;
    ArgumentList arguments;
    Token[] content;

    this(ref Token[] tokens) {
        this.returnType = convert(tokens);
        this.id = convert(tokens);
        expect(tokens, "(");
        this.arguments = new ArgumentList(tokens);
        expect(tokens, "{");
        uint parensCount = 1;
        while (true) {
            assert(tokens.length > 0, "expected '}'");
            Token token = tokens[0];
            tokens = tokens[1..$];
            if (token.str == "//") {
                content ~= token;
                content ~= tokens[0];
                tokens = tokens[1..$];
            } else if (token.str == "{") {
                parensCount++;
                content ~= token;
            } else if (token.str == "}") {
                parensCount--;
                if (parensCount == 0) break;
                content ~= token;
            } else {
                content ~= token;
            }
        }
    }

    static generateFunction(string funcName, string typeName, string[] arguments, string[] contents) {
        auto tokens = tokenize(format!"%s %s(%s) {\n  %s\n}"(typeName, funcName, arguments.join(","), contents.join("\n  ")));
        return new FunctionDeclare(tokens); 
    }

    override string graph(bool[] isEnd) {
        string code = indent(isEnd[0..$-1]) ~ "|---Function\n";
        code ~= indent(isEnd) ~ "|---" ~ this.returnType ~ "\n";
        code ~= this.arguments.graph(isEnd ~ true);
        return code;
    }

    override string getCode() {
        string contentCode;
        auto beforeLine = content[0].line;
        auto beforeColumn = 0;
        foreach (token; content) {
            if (token.line > beforeLine) {
                contentCode ~= repeat('\n', token.line - beforeLine).array;
                beforeLine = token.line;
                beforeColumn = 0;
            }
            assert(token.column >= beforeColumn);
            contentCode ~= repeat(' ', token.column - beforeColumn).array;
            beforeColumn = token.column + cast(uint)token.str.length;
            contentCode ~= token.str;
        }
        return format!"%s %s(%s) {\n%s\n}"(this.returnType, this.id, this.arguments.getCode(), contentCode);
    }

    void replaceID(string delegate(string) replace, string[] IDs) {
        //変更によってcolumnがズレる
        uint offset = 0;
        uint beforeLine = this.content[0].line;
        this.id = replace(this.id);
        this.arguments.replaceID(replace);
        foreach (ref c; this.content) {
            if (c.line > beforeLine) {
                beforeLine = c.line;
                offset = 0;
            }
            c.column += offset;
            if (IDs.all!(id => id != c.str
                && (c.str.split(".").length < 2 ||  c.str.split(".")[0] != id))) continue;
            auto len = c.str.length;
            c.str = replace(c.str);
            offset += cast(uint)c.str.length - len;
        }
    }

    string[] getIDs() {
        return id ~ this.arguments.arguments.map!(arg => arg.id).array;
    }

    void insertIdOutput(string inputName, string outputName) {
        auto newContent = tokenize(format!"%s = vec4(vec3(%s), 1);"(outputName, inputName));
        foreach (c; newContent)
            c.line += this.content[$-1].line+1;
        this.content ~= newContent;
    }
}
