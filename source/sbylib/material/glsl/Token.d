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
enum Symbol = [';', '{', '}', '(', ')', ',', '#'];

Token[] tokenize(string code) {
    return tokenizeNormal(code, null, new Token[0], 1, 0);
}

Token[] tokenizeNormal(string code, Token buffer, Token[] tokens, uint line, uint column) {
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
        return tokenizeNormal(code[1..$], null, tokens, line, column);
    }
    if (Symbol.any!(s => s == c)) {
        if (buffer) {
            tokens ~= buffer;
        }
        tokens ~= new Token(to!string(c), line, column);
        if (tokens.length >= 2 && tokens[$-2].str == ")" && tokens[$-1].str == "{") {
            return tokenizeFunction(code[1..$], new Token("", line, column), tokens, line, column, 1);
        } else {
            return tokenizeNormal(code[1..$], null, tokens, line, column);
        }
    }
    if (!buffer) {
        buffer = new Token("", line, column);
    }
    buffer.str ~= c;
    return tokenizeNormal(code[1..$], buffer, tokens, line, column);
}

Token[] tokenizeFunction(string code, Token buffer, Token[] tokens, uint line, uint column, uint parensCount) {
    if (code.length == 0) return tokens;
    column++;
    const c = code[0];
    if (c == '{') {
        buffer.str ~= c;
        return tokenizeFunction(code[1..$], buffer, tokens, line, column, parensCount + 1);
    }
    if (c == '}') {
        if (parensCount == 1) {
            tokens ~= buffer;
            tokens ~= new Token("}", line, column);
            return tokenizeNormal(code[1..$], null, tokens, line, column);
        }
        buffer.str ~= c;
        return tokenizeFunction(code[1..$], buffer, tokens, line, column, parensCount - 1);
    }
    buffer.str ~= c;
    if (c == '\n') {
        column = 0;
        line++;
    }
    return tokenizeFunction(code[1..$], buffer, tokens, line, column, parensCount);
}
