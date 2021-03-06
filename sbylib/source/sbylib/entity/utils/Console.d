module sbylib.entity.utils.Console;

import sbylib;
import std.algorithm, std.range, std.string, std.array, std.conv, std.regex, std.stdio;

class Console : MultiLineLabel {

    protected string inputString;
    protected int cursor;

    alias rect this;

    static add() {
        auto world = new World;
        auto renderer = createRenderer2D(world, Core().getWindow().getScreen());
        world.add(new Console);
        Core().addProcess({
            renderer.renderAll();
        }, "console render");
    }

    this() {
        this.addProcess({
            Core().justPressedKey().apply!((KeyButton button) {
                handle(button);
                renderForConsole();
            });
        });
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

    protected void handle(KeyButton key) {
        import std.ascii;
        if (isPrintable(key)) {
            insertToCursor(getChar(key));
        } else if (key == KeyButton.Enter) {
            breakLine();
        } else if (key == KeyButton.BackSpace) {
            removeBeforeCharacter();
        } else if (key == KeyButton.Delete) {
            removeAfterCharacter();
        } else if (key == KeyButton.Left) {
            moveCursor(-1);
        } else if (key == KeyButton.Right) {
            moveCursor(+1);
        }
    }

    private void insertToCursor(char c) {
        inputString = inputString[0..cursor] ~ c ~ inputString[cursor..$];
        this.cursor++;
    }

    private void breakLine() {
        text = text ~ [WHITE(inputString)];
        this.inputString = "";
        this.cursor = 0;
    }

    private void removeBeforeCharacter() {
        if (cursor == 0) return;

        this.inputString = this.inputString[0..cursor-1] ~ this.inputString[cursor..$];
        this.cursor--;
    }

    private void removeAfterCharacter() {
        if (cursor == this.inputString.length) return;

        this.inputString = this.inputString[0..cursor] ~ this.inputString[cursor+1..$];
    }

    private void moveCursor(int d) {
        cursor += d;
        if (cursor < 0) cursor = 0;
        if (cursor >= this.inputString.length) cursor = cast(int)this.inputString.length-1;
    }

    protected void renderForConsole() {
        auto lastLine = inputString;
        lastLine = inputString[0..cursor] ~ "|" ~ lastLine[cursor..$];
        render(text ~ [WHITE(lastLine)]);
    }

    protected char getChar(KeyButton key) {
        if (auto r = key in CharList) return shift ? r.shiftChar : r.normalChar;
        if (shift) return cast(char)key;
        return cast(char)key.toLower;
    }

    protected bool shift() {
        return Core().isPressed(KeyButton.LeftShift) || Core().isPressed(KeyButton.RightShift);
    }

    protected bool ctrl() {
        return Core().isPressed(KeyButton.LeftControl) || Core().isPressed(KeyButton.RightControl);
    }
}
