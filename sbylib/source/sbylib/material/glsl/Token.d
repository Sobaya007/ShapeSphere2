module sbylib.material.glsl.Token;

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

Token[] tokenize(string code) {
    return tokenize(code, null, new Token[0], 1, 0);
}

private Token[] tokenize(string code, Token buffer, Token[] tokens, uint line, uint column) {
    import std.array;

    if (code.empty) {
        tokens.addToken(buffer);
        return tokens;
    }

    char frontCharacter = code[0];

    if (frontCharacter.isDelimitor()) {
        tokens.addToken(buffer);
        if (frontCharacter.isBreak()) {
            return tokenize(code[1..$], null, tokens, line+1, 0);
        } else {
            return tokenize(code[1..$], null, tokens, line, column+1);
        }
    }
    if (frontCharacter.isSymbol()) {
        import std.conv : to;

        tokens.addToken(buffer);
        tokens.addToken(new Token(frontCharacter.to!string, line, column));
        return tokenize(code[1..$], null, tokens, line, column+1);
    }
    if (code.isBeginningOfLineComment) {
        return tokenizeLineComment(code[2..$], tokens, line, column+2);
    }
    if (code.isBeginningOfBlockComment) {
        return tokenizeBlockComment(code[2..$], tokens, line, column+2);
    }
    if (buffer is null) {
        buffer = new Token("", line, column);
    }
    buffer.str ~= frontCharacter;
    return tokenize(code[1..$], buffer, tokens, line, column+1);
}

private Token[] tokenizeLineComment(string code, Token[] tokens, uint line, uint column) {
    import std.algorithm : countUntil;
    import std.conv : to;

    auto count = code.countUntil!(isBreak);
    if (count == -1) count = code.length;
    tokens.addToken(new Token("//" ~ code[0..count], line, column));
    return tokenize(code[count..$], null, tokens, line+1, 0);
}

private Token[] tokenizeBlockComment(string code, Token[] tokens, uint line, uint column) {
    import std.algorithm : countUntil;
    import std.conv : to;

    int count = 0;
    while (count < code.length && code[count..$].isEndOfBlockComment) count++;
    if (count < code.length-1) count++; // because end of blocks comment consists of two characters.
    tokens.addToken(new Token("/*" ~ code[0..count], line, column));
    return tokenize(code[count..$], null, tokens, line+1, 0);
}

private void addToken(ref Token[] tokens, Token newToken) {
    if (newToken !is null) tokens ~= newToken;
}

private bool isDelimitor(dchar c) {
    return c == ' ' || c == '\t' || c == '\n' || c == '\r';
}

private bool isSymbol(dchar c) {
    import std.algorithm : canFind;

    enum Symbol = [';', '{', '}', '(', ')', ',', '#', '+', '-', '*', '/'];
    static foreach (s; Symbol) {
        if (c == s) return true;
    }
    return false;
}

bool isBreak(dchar c) {
    return c == '\n' || c == '\r';
}

private bool isBeginningOfLineComment(string str) {
    return str.length >= 2 && str[0..2] == "//";
}

private bool isBeginningOfBlockComment(string str) {
    return str.length >= 2 && str[0..2] == "/*";
}

bool isEndOfBlockComment(string str) {
    return str.length >= 2 && str[0..2] == "*/";
}