module game.Console;

import sbylib;
import game.Game;
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
        if (mode == 1) {
            mode++;
            render();
            return;
        }
        Core().getKey().preventCallback();
        Game.getMap().pause();
        auto mKey = Core().getKey().justPressedKey();
        if (mKey.isNone) return;
        handle(mKey.get());
        render();
    }

    void on() {
        this.mode = 1;
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
            auto shift = Core().getKey().isPressed(KeyButton.LeftShift) || Core().getKey().isPressed(KeyButton.RightShift);
            auto c = shift ? cast(char)key : (cast(char)key).toLower;
            if (auto r = key in CharList) c = shift ? r.shiftChar : r.normalChar;
            text.back = slice(text.back,0,cursor)~c~slice(text.back,cursor, text.back.length);
            cursor++;
        } else if (key == KeyButton.Enter) {
            auto input = text.back;
            if (!input.empty) {
                history ~= input;
                historyCursor = cast(int)history.length;
                text ~= interpret(input)
                    .split("\n")
                    .map!(s => s.indent(4))
                    .array;
            }
            text ~= "";
            cursor = 0;
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
            mode = 0;
            Core().getKey().allowCallback();
            Game.getMap().resume();
            text = [""];
            cursor = 0;
        } else if (key == KeyButton.Tab) {
            auto cs = candidates(text.back);
            if (!cs.empty) {
                string[] output = cs
                    .map!(s => s.indent(4))
                    .array;
                text ~= output;
                text ~= cs.reduce!commonPrefix;
                cursor = cast(int)text.back.length;
            }
        }
        text = text.tail(LINE_NUM);
    }

    private string slice(string s, size_t i, size_t j) {
        if (i > j) return "";
        if (i < 0) return "";
        if (j > s.length) return "";
        return s[i..j];
    }

    private void render() {
        auto lastLine = text.back;
        lastLine = slice(lastLine,0,cursor)~'|'~slice(lastLine,cursor, lastLine.length);
        label.renderText(text.dropBack(1).map!(t=>" "~t).join('\n')~'\n'~(mode?'>':':')~lastLine);
        label.left = -1;
        label.bottom = -1;
    }

    interface Selectable {
        string[] childNames();
        Selectable[] findChild(string);
        string getInfo();

        final string interpret(string[] tokens) {
            if (tokens.empty) return getInfo();
            auto token = tokens.front;
            tokens.popFront();
            if (token == ">") {
                if (token.empty) return "Put <name> after '>'";

                auto name = tokens.front();
                tokens.popFront();

                auto next = search(name);

                return next.interpret(tokens).getOrElse(format!"No match name for '%s'"(name));
            }
            return format!"Invalid token: '%s'"(token);
        }

        final string[] candidates(string[] tokens, string before) {
            if (tokens.empty) return summarySameName(childNames).map!(s => before~s).array;
            auto token = tokens.front;
            tokens.popFront();
            if (token == ">") {
                if (tokens.empty) return summarySameName(childNames).map!(s => before~s).array;
                
                auto name = tokens.front();
                tokens.popFront();

                auto next = search(name);

                return next.candidates(tokens, before~name~">").getOrElse(filterCandidates(summarySameName(childNames), name).map!(s => before~s).array);
            }
            return [];
        }

        final Maybe!Selectable search(string name) {
            auto r = ctRegex!"\\[([0-9]*)\\]";
            auto c = matchFirst(name, r);
            if (!c.empty) {
                auto res = findChild(c.pre).drop(c.hit.dropOne.dropBackOne.to!int);
                return res.empty ? None!Selectable : Just(res.front);
            } else {
                auto res = findChild(name);
                return res.empty ? None!Selectable : Just(res.front);
            }
        }

        final auto summarySameName(string[] candidates) {
            return candidates.sort.group.map!(g => g[1] == 1 ? g[0] : g[0]~"[").array;
        }

        final auto filterCandidates(string[] candidates, string current) {
            writeln(candidates);
            writeln(current);
            writeln(candidates.filter!(s => s.toLower.startsWith(current.toLower)).array);
            return candidates.filter!(s => s.toLower.startsWith(current.toLower)).array;
        }
    }

    class RootSelection : Selectable {
        override string[] childNames() {
            return ["world3d", "world2d"];
        }

        override Selectable[] findChild(string name) {
            if (name == "world3d") return [new WorldSelection(Game.getWorld3D)];
            if (name == "world2d") return [new WorldSelection(Game.getWorld2D)];
            return null;
        }

        override string getInfo() {
            return null;
        }
    }

    class WorldSelection : Selectable {

        private World world;

        this(World world) {this.world = world;}

        override string[] childNames() {
            return world.getEntities.map!(e => e.name).array;
        }

        override Selectable[] findChild(string name) {
            return world.getEntities.find!(e => e.name == name).map!(e => cast(Selectable)new EntitySelection(e)).array;
        }

        override string getInfo() {
            return world.toString((Entity e) => e.name, false).split("\n").sort.group.map!(p => p[1] == 1 ? p[0] : format!"%s[%d]"(p[0], p[1])).join("\n");
        }
    }

    class EntitySelection : Selectable {

        private Entity entity;

        this(Entity entity) {this.entity = entity;}

        override string[] childNames() {
            return entity.getChildren.map!(e => e.name).array ~ ["pos", "rot", "scale"];
        }

        override Selectable[] findChild(string name) {
            auto children = entity.getChildren.find!(e => e.name == name).map!(e => cast(Selectable)new EntitySelection(e)).array;
            if (!children.empty) return children;
            if (name == "pos") return [new PositionSelection(entity)];
            return null;
        }

        override string getInfo() {
            return entity.toString(false);
        }
    }

    class PositionSelection : Selectable {
        private Entity entity;
        this(Entity entity) {this.entity = entity;}

        override string[] childNames() {
            return ["x", "y", "z"];
        }

        override Selectable[] findChild(string name) {
            return null;
        }

        override string getInfo() {
            return entity.pos.toString;
        }
    }

    private string interpret(string str) {
        auto tokens = (">" ~ str).splitter!(Yes.keepSeparators)(ctRegex!"[>=]").array;

        return new RootSelection().interpret(tokens);
    }

    private string[] candidates(string str) {
        auto tokens = (">" ~ str).splitter!(Yes.keepSeparators)(ctRegex!"[>=]").array;

        return new RootSelection().candidates(tokens, "");
    }
}
