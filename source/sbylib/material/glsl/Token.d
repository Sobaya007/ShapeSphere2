module sbylib.material.glsl.Token;
import std.conv;
import std.algorithm;

class Token {
    string str;
    uint line;
    uint column;

    this(string str, uint line, uint column) {
        this.str = str;
        this.line = line;
        this.column = column;
    }

    override string toString() {
        return str;
    }
}

enum Delimitor = [' ', '\t', '\n', '\r'];
enum Symbol = [';', '{', '}', '(', ')', ',', '#', '+', '-', '*'];

Token[] tokenize(string code) {
    auto po = tokenize(code, null, new Token[0], 1, 0, false);
    return po;
}

Token[] tokenize(string code, Token buffer, Token[] tokens, uint line, uint column, bool commentFlag) {
    if (code.length == 0) {
        if (buffer) {
            tokens ~= buffer;
        }
        return tokens;
    }
    column++;
    const c = code[0];
    if (Delimitor.any!(d => d == c)) {
        if (c == '\n') {
            column = 0;
            line++;
        }
        if (buffer) {
            tokens ~= buffer;
        }
        return tokenize(code[1..$], null, tokens, line, column, false);
    }
    if (Symbol.any!(s => s == c)) {
        if (buffer) {
            tokens ~= buffer;
        }
        tokens ~= new Token(to!string(c), line, column);
        return tokenize(code[1..$], null, tokens, line, column, false);
    }
    if (c == '/') {
        if (commentFlag) {
            buffer.str ~= c;
            tokens ~= buffer;
            return tokenizeComment(code[1..$], tokens, line, column);
        } else {
            if (buffer) {
                tokens ~= buffer;
            }
            return tokenize(code[1..$], new Token("/", line, column), tokens, line, column, true);
        }
    }
    if (commentFlag) {
        tokens ~= buffer;
        buffer = null;
    }
    if (!buffer) {
        buffer = new Token("", line, column);
    }
    buffer.str ~= c;
    return tokenize(code[1..$], buffer, tokens, line, column, false);
}

Token[] tokenizeComment(string code, Token[] tokens, uint line, int column) {
    column++;
    uint pos = 0;
    while (code[pos] != '\n') pos++;
    Token buffer = new Token(code[0..pos], line, column);
    tokens ~= buffer;
    return tokenize(code[pos+1..$], null, tokens, line+1, 0, false);
}
