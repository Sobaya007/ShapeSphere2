module model.xfile.converter.XLexer;

import model.xfile.converter;
import model.xfile.XToken;

import std.conv,
       std.range,
       std.array,
       std.algorithm,
       std.string,
       std.ascii,
       std.concurrency,
       std.container : DList;

// XLexer: string -> XToken[]
class XLexer : XConverter!(string, XToken[]) {

    override XToken[] run(string src) {
        return tokenize(src);
    }

private:

    XToken[] tokenize(string src) {
        DList!XToken tokens;

        auto lookaheader = getLookaheader(src);

        string str = "";
        void insert() {
            if (!str.empty) {
                tokens.insertBack(new XTokenLabel(str));
                str = "";
            }
        }

        foreach(c; lookaheader) {
            if (c.isWhite) {
                insert();
            } else if (c == ',') {
                insert();
                tokens.insertBack(new XTokenComma);
            } else if (c == ';') {
                insert();
                tokens.insertBack(new XTokenSemicolon);
            } else if (c == '{') {
                insert();
                tokens.insertBack(new XTokenLeftParen);
            } else if (c == '}') {
                insert();
                tokens.insertBack(new XTokenRightParen);
            } else {
                str ~= c;
            }
        }

        return tokens[].array;
    }

    Generator!char getLookaheader(string src) {
        return new Generator!char({
            foreach(str; src.splitLines.dropOne) { // dropOneでヘッダ情報を落とす
                foreach(c; str.until("//").to!(char[])) { // until("//")でコメントアウト部分を落とす
                    c.yield;
                }
                ' '.yield; // 終端
            }
        });
    }

}

unittest {
    XLexer lexer = new XLexer;

    string src =
        "header\n" ~
        "po { // commentout\n" ~
        "0.0,1;\n" ~
        "\"sobaya.homo\"\n" ~
        "}\n";

    XToken[] tokens = lexer.run(src);
    assert(tokens.length == 8);
    assert(cast(XTokenLabel)tokens[0]      && tokens[0].lexeme == "po");
    assert(cast(XTokenLeftParen)tokens[1]  && tokens[1].lexeme == "{");
    assert(cast(XTokenLabel)tokens[2]      && tokens[2].lexeme == "0.0");
    assert(cast(XTokenComma)tokens[3]      && tokens[3].lexeme == ",");
    assert(cast(XTokenLabel)tokens[4]      && tokens[4].lexeme == "1");
    assert(cast(XTokenSemicolon)tokens[5]  && tokens[5].lexeme == ";");
    assert(cast(XTokenLabel)tokens[6] && tokens[6].lexeme == "\"sobaya.homo\"");
    assert(cast(XTokenRightParen)tokens[7] && tokens[7].lexeme == "}");
}
