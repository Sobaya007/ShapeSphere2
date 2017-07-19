module model.xfile.XToken;

import std.string;

abstract class XToken {
    int line;
    int column;
    string lexeme;
}

class XTokenComma : XToken {
    this(int line, int column) {
        this.line = line;
        this.column = column;
        this.lexeme = ",";
    }
    override string toString() {
        return format("XTokenComma(\"%s\")", this.lexeme);
    }
}

class XTokenSemicolon : XToken {
    this(int line, int column) {
        this.line = line;
        this.column = column;
        this.lexeme = ";";
    }
    override string toString() {
        return format("XTokenSemicolon(\"%s\")", this.lexeme);
    }
}

class XTokenLeftParen : XToken {
    this(int line, int column) {
        this.line = line;
        this.column = column;
        this.lexeme = "{";
    }
    override string toString() {
        return format("XTokenLeftParen(\"%s\")", this.lexeme);
    }
}

class XTokenRightParen : XToken {
    this(int line, int column) {
        this.line = line;
        this.column = column;
        this.lexeme = "}";
    }
    override string toString() {
        return format("XTokenRightParen(\"%s\")", this.lexeme);
    }
}

class XTokenLabel : XToken {
    this(int line, int column, string lexeme) {
        this.line = line;
        this.column = column;
        this.lexeme = lexeme;
    }
    override string toString() {
        return format("XTokenLabel(\"%s\")", this.lexeme);
    }
}
