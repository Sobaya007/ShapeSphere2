module sbylib.entity.utils.Console;

import sbylib;
import std.algorithm, std.range, std.string, std.array, std.conv, std.regex, std.stdio;

class Console {

    Label label;
    Entity rect;
    protected string[] text;
    protected int cursor;

    alias rect this;

    static add() {
        auto world = new World;
        auto renderer = createRenderer2D(world, Core().getWindow().getScreen());
        world.add(new Console);
        Core().addProcess({
            renderer.render();
        }, "console render");
    }

    this() {
        LabelFactory factory;
        factory.fontName = "RictyDiminished-Regular-Powerline.ttf";
        factory.height = 24.pixel;
        factory.strategy = Label.Strategy.Left;
        factory.backColor = vec4(0);
        factory.textColor = vec4(1,1,1,1);
        factory.wrapWidth = Core().getWindow().width;
        factory.text = "";

        this.label = factory.make();
        label.pos.z = 0.1;
        this.label.addProcess({
            Core().justPressedKey().apply!((KeyButton button) {
                handle(button);
                render();
            });
        });

        this.rect = makeEntity(Rect.create(Core().getWindow.width, Core().getWindow().height), new ColorMaterial(vec4(vec3(0), 0.5)));
        this.rect.pos.z = -0.01;
        //this.label.addChild(this.rect);
        this.rect.addChild(this.label);

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
        import std.array : back;
        text.back = text.back[0..cursor] ~ c ~ text.back[cursor..$];
        this.cursor++;
    }

    private void breakLine() {
        text = text ~ [""];
        this.cursor = 0;
    }

    private void removeBeforeCharacter() {
        if (cursor == 0) return;

        import std.array : back;
        text.back = text.back[0..cursor-1] ~ text.back[cursor..$];
        this.cursor--;
    }

    private void removeAfterCharacter() {
        import std.array : back;

        if (cursor == text.back.length) return;

        text.back = text.back[0..cursor] ~ text.back[cursor+1..$];
    }

    private void moveCursor(int d) {
        import std.array : back;

        cursor += d;
        if (cursor < 0) cursor = 0;
        if (cursor >= text.back.length) cursor = cast(int)text.back.length-1;
    }

    protected void render() {
        auto strs = text.dup;
        strs[$-1] = strs[$-1][0..cursor] ~ "|" ~ strs[$-1][cursor..$];
        render(strs);
    }

    protected final void render(string[] strs) {
        label.renderText(strs.join('\n'));
        label.left = -Core().getWindow().width/2;
        label.bottom = -Core().getWindow().height/2;
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
