module model.xfile.converter.XLexer;

import model.xfile.converter;

import std.conv,
       std.range,
       std.array,
       std.algorithm,
       std.string,
       std.ascii,
       std.concurrency,
       std.container : DList;

// XLexer: string -> DList!XToken
class XLexer : XConverter!(string, DList!XToken) {

    override DList!XToken run(string src) {
        return tokenize(src);
    }

private:

    DList!XToken tokenize(string src) {
        DList!XToken tokens;

        auto lookaheader = getLookaheader(src);

        DList!Node label;
        void insert() {
            if (!label.empty) {
                int line      = label.front.line;
                int column    = label.front.column;
                string lexeme = label[].map!"a.character".to!string;
                tokens.insertBack(new XTokenLabel(line, column, lexeme));
                label.clear;
            }
        }

        foreach(node; lookaheader) {
            if (node.character.isWhite) {
                insert();
            } else if (node.character == ',') {
                insert();
                tokens.insertBack(new XTokenComma(node.line, node.column));
            } else if (node.character == ';') {
                insert();
                tokens.insertBack(new XTokenSemicolon(node.line, node.column));
            } else if (node.character == '{') {
                insert();
                tokens.insertBack(new XTokenLeftParen(node.line, node.column));
            } else if (node.character == '}') {
                insert();
                tokens.insertBack(new XTokenRightParen(node.line, node.column));
            } else {
                label.insertBack(node);
            }
        }
        import std.stdio;
        writeln("lexer finshed");

        return tokens;
    }

    Generator!Node getLookaheader(string src) {
        return new Generator!Node({
            foreach(int line, str; src.splitLines) {
                if (line == 0) continue; // ヘッダ情報を落とす
                foreach(int column, character; str.until("//").to!(char[])) { // until("//")でコメントアウト部分を落とす
                    Node(line + 1, character + 1, character).yield;
                }
                Node(-1, -1, ' ').yield; // 終端
            }
        });
    }

    struct Node {
        int line;
        int column;
        char character;
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

    XToken[] tokens = lexer.run(src)[].array;
    assert(tokens.length == 8);
    assert(cast(XTokenLabel)tokens[0]      && tokens[0].lexeme == "po");
    assert(cast(XTokenLeftParen)tokens[1]  && tokens[1].lexeme == "{");
    assert(cast(XTokenLabel)tokens[2]      && tokens[2].lexeme == "0.0");
    assert(cast(XTokenComma)tokens[3]      && tokens[3].lexeme == ",");
    assert(cast(XTokenLabel)tokens[4]      && tokens[4].lexeme == "1");
    assert(cast(XTokenSemicolon)tokens[5]  && tokens[5].lexeme == ";");
    assert(cast(XTokenLabel)tokens[6]      && tokens[6].lexeme == "\"sobaya.homo\"");
    assert(cast(XTokenRightParen)tokens[7] && tokens[7].lexeme == "}");
}
