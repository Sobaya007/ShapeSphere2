module game.console.Console;

import sbylib;
import game.Game;
import game.console.selections;
import std.algorithm, std.range, std.string, std.array, std.conv, std.regex, std.stdio;

debug class Console {

    private int mode = 0;
    private enum LINE_NUM = 30;
    Label label;
    private string[] text;
    private string[] history;
    private string lastOutput; // for copy
    private int cursor, historyCursor;

    alias label this;

    this() {
        LabelFactory factory;
        factory.fontName = "RictyDiminished-Regular-Powerline.ttf";
        factory.height = 24.pixel;
        factory.strategy = Label.Strategy.Left;
        factory.backColor = vec4(0,0,0,0.5);
        factory.textColor = vec4(1,1,1,1);
        factory.wrapWidth = Core().getWindow().width;
        factory.text = ":";

        this.label = factory.make();
        this.label.addProcess({
            label.left = -Core().getWindow().width/2;
            label.bottom = -Core().getWindow().height/2;
        });
        label.pos.z = 0.1;
        Game.getWorld2D.add(label);

        this.text = [""];
        this.history = [""];
    }

    void step() {
        if (mode == 0) return;
        if (mode == 1) { //こうしないとiが入っちゃう
            mode++;
            render();
            return;
        }
        auto mKey = Core().justPressedKey();
        if (mKey.isNone) return;
        handle(mKey.unwrap());
        render();
    }

    void on() {
        this.mode = 1;
        this.cursor = 0;
        Core().preventCallback();
        Controller().available = false;
        Game.getMap().pause();
        text = [""];
    }

    void off() {
        this.mode = 0;
        this.cursor = 0;
        Core().allowCallback();
        Controller().available = true;
        Game.getMap().resume();
        text = [""];
    }

    struct CharPair {
        char normalChar;
        char shiftChar;
    }

    enum CharList = [
        KeyButton.Key1         : CharPair('1' , '!' ),
        KeyButton.Key2         : CharPair('2' , '"' ),
        KeyButton.Key3         : CharPair('3' , '#' ),
        KeyButton.Key4         : CharPair('4' , '$' ),
        KeyButton.Key5         : CharPair('5' , '%' ),
        KeyButton.Key6         : CharPair('6' , '&' ),
        KeyButton.Key7         : CharPair('7' , '\''),
        KeyButton.Key8         : CharPair('8' , '(' ),
        KeyButton.Key9         : CharPair('9' , ')' ),
        KeyButton.Comma        : CharPair(',' , '<' ),
        KeyButton.Minus        : CharPair('-' , '=' ),
        KeyButton.Period       : CharPair('.' , '>' ),
        KeyButton.Slash        : CharPair('/' , '?' ),
        KeyButton.Semicolon    : CharPair(';' , '+' ),
        KeyButton.LeftBracket  : CharPair('[' , '{' ),
        KeyButton.RightBracket : CharPair(']' , '}' ),
        KeyButton.AtMark       : CharPair('@' , '`' ),
        KeyButton.Hat          : CharPair('^' , '~' ),
        KeyButton.BackSlash1   : CharPair('\\', '|' ),
        KeyButton.BackSlash2   : CharPair('\\', '_' )
    ];

    private void handle(KeyButton key) {
        scope (exit) text = text.tail(LINE_NUM);
        import std.ascii;
        auto shift = Core().isPressed(KeyButton.LeftShift) || Core().isPressed(KeyButton.RightShift);
        auto ctrl = Core().isPressed(KeyButton.LeftControl) || Core().isPressed(KeyButton.RightControl);
        if (ctrl && shift && key == KeyButton.Semicolon) {
            this.label.size *= 1.01;
        } else if (ctrl && shift && key == KeyButton.Minus) {
            this.label.size /= 1.01;
        } else if (ctrl && key == KeyButton.KeyC) {
            Core().getClipboard().set(lastOutput.to!dstring);
        } else if (isPrintable(key)) {

            insertToCursor(getChar(key, shift));

        } else if (key == KeyButton.Enter) {

            auto input = text.back;

            if (input.empty) return;

            pushHistory(input);

            auto output = interpret(input);
            show(output.split("\n"));

        } else if (key == KeyButton.BackSpace) {

            text.back = slice(text.back,0,cursor-1)~slice(text.back,cursor, text.back.length);
            cursor = max(0, cursor-1);

        } else if (key == KeyButton.Left) {

            cursor = max(0, cursor-1);

        } else if (key == KeyButton.Right) {

            cursor = min(text.back.length, cursor+1);

        } else if (key == KeyButton.Up) {

            historyCursor = max(0, historyCursor-1);
            text.back = history[historyCursor];
            cursor = cast(int)text.back.length;

        } else if (key == KeyButton.Down) {

            historyCursor = min(history.length, historyCursor+1);
            text.back = historyCursor < history.length ? history[historyCursor] : "";
            cursor = cast(int)text.back.length;

        } else if (key == KeyButton.Escape) {

            off();

        } else if (key == KeyButton.Tab) {

            auto input = text.back;

            auto cs = candidates(input);

            if (cs.empty) return;

            auto output = cs
                .sort!((a,b) => a.name < b.name)
                .group!((a,b) => a.name == b.name)
                .map!(p => p[1] == 1 ? p[0].screenName : format!"%s[%d]"(p[0].name, p[1]))
                .array;
            show(output);

            text ~= cs
                .sort!((a,b) => a.name < b.name)
                .map!(p => p.absoluteName)
                .reduce!commonPrefix
                .dropOne;
            cursor = cast(int)text.back.length;
        }
    }

    private char getChar(KeyButton key, bool shift) {
        if (auto r = key in CharList) return shift ? r.shiftChar : r.normalChar;
        if (shift) return cast(char)key;
        return cast(char)key.toLower;
    }

    private void insertToCursor(char c) {
        this.text.back = slice(text.back,0,cursor)~c~slice(text.back,cursor, text.back.length);
        this.cursor++;
    }

    private void show(string[] strs) {
        enum MAX_LENGTH = 40;
        text ~= strs
            .map!(s => s.length < MAX_LENGTH ? s : s[0..MAX_LENGTH/2]~"..."~s[$-MAX_LENGTH/2-3..$])
            .map!(s => s.indent(4))
            .array;
        text ~= "";
        cursor = 0;
        this.lastOutput = strs.join("\n");
    }

    private void pushHistory(string command) {
        if (command.empty) return;
        history ~= command;
        historyCursor = cast(int)history.length;
    }

    private void render() {
        auto lastLine = text.back;
        lastLine = slice(lastLine,0,cursor)~'|'~slice(lastLine,cursor, lastLine.length);
        label.renderText(text.dropBack(1).map!(t=>" "~t).join('\n')~'\n'~(mode==0?":":">")~lastLine);
    }

    private string interpret(string str) {
        auto tokens = (">" ~ str).splitter!(Yes.keepSeparators)(ctRegex!"[>=]").array;

        return new RootSelection().interpret(TokenList(tokens));
    }

    private Selectable[] candidates(string str) {
        auto tokens = (">" ~ str).splitter!(Yes.keepSeparators)(ctRegex!"[>=]").array;

        return new RootSelection().candidates(TokenList(tokens));
    }

    private string slice(string s, size_t i, size_t j) {
        if (i > j) return "";
        if (i < 0) return "";
        if (j > s.length) return "";
        return s[i..j];
    }
}
