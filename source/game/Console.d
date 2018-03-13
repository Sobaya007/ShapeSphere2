module game.Console;

import sbylib;
import game.Game;
import game.ConsoleSelection;
import std.algorithm, std.range, std.string, std.array, std.conv, std.regex, std.stdio;

debug class Console {

    private int mode = 0;
    private enum LINE_NUM = 30;
    Label label;
    private string[] text;
    private string[] history;
    private int cursor, historyCursor;

    alias label this;

    this() {
        LabelFactory factory;
        factory.fontName = "RictyDiminished-Regular-Powerline.ttf";
        factory.height = 0.06;
        factory.strategy = Label.Strategy.Left;
        factory.backColor = vec4(0,0,0,0.5);
        factory.textColor = vec4(1,1,1,1);
        factory.text = ":";

        this.label = factory.make();
        label.left = -1;
        label.bottom = -1;
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
        auto mKey = Core().getKey().justPressedKey();
        if (mKey.isNone) return;
        handle(mKey.get());
        render();
    }

    void on() {
        this.mode = 1;
        this.cursor = 0;
        Core().getKey().preventCallback();
        Controller().available = false;
        Game.getMap().pause();
        text = [""];
    }

    void off() {
        this.mode = 0;
        this.cursor = 0;
        Core().getKey().allowCallback();
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
        import std.ascii;
        if (isPrintable(key)) {

            insertToCursor(getChar(key));

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

            auto output = candidates(input);

            if (output.empty) return;

            show(output);

            text ~= output.reduce!commonPrefix;
            cursor = cast(int)text.back.length;
        }
        text = text.tail(LINE_NUM);
    }

    private char getChar(KeyButton key) {
        auto shift = Core().getKey().isPressed(KeyButton.LeftShift) || Core().getKey().isPressed(KeyButton.RightShift);
        if (auto r = key in CharList) return shift ? r.shiftChar : r.normalChar;
        if (shift) return cast(char)key;
        return cast(char)key.toLower;
    }

    private void insertToCursor(char c) {
        this.text.back = slice(text.back,0,cursor)~c~slice(text.back,cursor, text.back.length);
        this.cursor++;
    }

    private void show(string[] strs) {
        text ~= strs
            .map!(s => s.indent(4))
            .array;
        text ~= "";
        cursor = 0;
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
        label.left = -1;
        label.bottom = -1;
    }

    private string interpret(string str) {
        auto tokens = (">" ~ str).splitter!(Yes.keepSeparators)(ctRegex!"[>=]").array;

        return new RootSelection().interpret(tokens);
    }

    private string[] candidates(string str) {
        auto tokens = (">" ~ str).splitter!(Yes.keepSeparators)(ctRegex!"[>=]").array;

        return new RootSelection().candidates(tokens, "");
    }

    private string slice(string s, size_t i, size_t j) {
        if (i > j) return "";
        if (i < 0) return "";
        if (j > s.length) return "";
        return s[i..j];
    }
}
