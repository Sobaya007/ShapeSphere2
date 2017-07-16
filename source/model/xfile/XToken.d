module model.xfile.XToken;

import std.string;

interface XToken {
    string lexeme();
}

class XTokenComma : XToken {
    override string lexeme() {
        return ",";
    }
    override string toString() {
        return format("XTokenComma(\"%s\")", lexeme());
    }
}

class XTokenSemicolon : XToken {
    override string lexeme() {
        return ";";
    }
    override string toString() {
        return format("XTokenSemicolon(\"%s\")", lexeme());
    }
}

class XTokenLeftParen : XToken {
    override string lexeme() {
        return "{";
    }
    override string toString() {
        return format("XTokenLeftParen(\"%s\")", lexeme());
    }
}

class XTokenRightParen : XToken {
    override string lexeme() {
        return "}";
    }
    override string toString() {
        return format("XTokenRightParen(\"%s\")", lexeme());
    }
}

class XTokenLabel : XToken {
    private string _lexeme;
    this(string _lexeme) {
        this._lexeme = _lexeme;
    }
    override string lexeme() {
        return _lexeme;
    }
    override string toString() {
        return format("XTokenLabel(\"%s\")", lexeme());
    }
}
