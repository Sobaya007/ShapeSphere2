module game.Console;

import sbylib;
import game.Game;
import std.algorithm, std.range, std.string, std.array, std.conv;

debug class Console {

    private int mode = 0;
    private enum LINE_NUM = 30;
    Label label;
    private string[] text;
    private string[] history;
    private long cursor, historyCursor;

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

    private void handle(KeyButton key) {
        import std.ascii;
        if (isPrintable(key)) {
            auto shift = Core().getKey().isPressed(KeyButton.LeftShift) || Core().getKey().isPressed(KeyButton.RightShift);
            auto c = shift ? cast(char)key : (cast(char)key).toLower;
            if (c == '.' && shift) c = '>';
            if (key == KeyButton.LeftBracket) c = '[';
            if (key == KeyButton.RightBracket) c = ']';
            text.back = slice(text.back,0,cursor)~c~slice(text.back,cursor, text.back.length);
            cursor++;
        } else if (key == KeyButton.Enter) {
            auto input = text.back;
            if (!input.empty) {
                history ~= input;
                historyCursor = history.length;
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
            cursor = text.back.length;
        } else if (key == KeyButton.Down) {
            historyCursor = min(history.length, historyCursor+1);
            text.back = historyCursor < history.length ? history[historyCursor] : "";
            cursor = text.back.length;
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
                cursor = text.back.length;
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

    private string interpret(string str) {
        auto tokens = str.split('>');
        if (tokens.empty) return "";

        if (tokens.front == "world3d") {
            return interpret(Game.getWorld3D, tokens.dropOne);
        } else if (tokens.front == "world2d") {
            return interpret(Game.getWorld2D, tokens.dropOne);
        }
        return format!"No match pattern for '%s'"(tokens.front);
    }

    private string interpret(World world, string[] tokens) {
        if (tokens.empty) return world.toString((Entity e) => e.name, false).split("\n").sort.group.map!(p => p[1] == 1 ? p[0] : format!"%s[%d]"(p[0], p[1])).join("\n");
        import std.regex;
        auto r = ctRegex!"\\[([0-9]*)\\]";
        auto c = matchFirst(tokens.front, r);
        Maybe!Entity child;
        if (!c.empty) {
            auto res = world.findByName(c.pre).drop(c.hit.dropOne.dropBackOne.to!int);
            child = res.empty ? None!Entity : Just(res.front);
        } else {
            auto res = world.findByName(tokens.front);
            child = res.empty ? None!Entity : Just(res.front);
        }
        if (child.isNone) return format!"No match name for '%s'"(tokens.front);
        return interpret(child.get(), tokens.dropOne);
    }

    private string interpret(Entity entity, string[] tokens) {
        if (tokens.empty) return entity.toString(false);
        auto token = tokens.front;
        switch (token) {
            case "pos": return entity.pos.toString;
            case "rot": return entity.rot.toString;
            case "scale": return entity.scale.toString;
            default:
        }
        import std.regex;
        auto r = ctRegex!"\\[([0-9]*)\\]";
        auto c = matchFirst(tokens.front, r);
        Maybe!Entity child;
        if (!c.empty) {
            auto res = entity.findByName(c.pre).drop(c.hit.dropOne.dropBackOne.to!int);
            child = res.empty ? None!Entity : Just(res.front);
        } else {
            auto res = entity.findByName(tokens.front);
            child = res.empty ? None!Entity : Just(res.front);
        }
        if (child.isNone) return format!"No match name for '%s'"(token);
        return interpret(child.get(), tokens.dropOne);
    }

    private string[] candidates(string[] strs, string head) {
        return strs.sort.group.map!(g => g[1] == 1 ? g[0] : g[0]~"[").filter!(s => s.toLower.startsWith(head.toLower)).array;
    }

    private string[] candidates(string str) {
        auto tokens = str.split('>');
        if (tokens.empty) return ["world3d", "world2d"];
        if (tokens.length == 1) return candidates(["world3d", "world2d"], tokens.front);
        if (tokens.front == "world3d") {
            return candidates(Game.getWorld3D, tokens.dropOne).map!(c => "world3d>"~c).array;
        } else if (tokens.front == "world2d") {
            return candidates(Game.getWorld2D, tokens.dropOne).map!(c => "world2d>"~c).array;
        }
        return [];
    }

    private string[] candidates(World world, string[] tokens) {
        if (tokens.length == 1) return candidates(world.getEntityNames, tokens.front);
        auto child = world.findByName(tokens.front);
        if (child.empty) return [];
        return candidates(child.front, tokens.dropOne).map!(c => tokens.front~">"~c).array;
    }

    private string[] candidates(Entity entity, string[] tokens) {
        if (tokens.length == 1) return candidates(["pos", "rot", "scale"]~entity.getChildren.map!(c=>c.name).array, tokens.front);
        auto child = entity.findByName(tokens.front);
        if (child.empty) return [];
        return candidates(child.front, tokens.dropOne).map!(c => tokens.front~">"~c).array;
}
    }
