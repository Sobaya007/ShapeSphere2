module game.console.Console;

import sbylib;
import game.Game;
import game.console.selections;
import std.algorithm, std.range, std.string, std.array, std.conv, std.regex, std.stdio;

class GameConsole : Console {

    private int mode = 0;
    private enum LINE_NUM = 30;
    private string[] history;
    private string lastOutput; // for copy
    private int historyCursor;

    alias rect this;

    static add() {
        auto world = Game.getWorld2D();
        auto console = new GameConsole;
        world.add(console);
        return console;
    }

    this() {
        super();
        this.text = [":"];
        this.history = [""];

        this.pos.z = 0.5;
        this.off();
    }

    protected override void handle(KeyButton key) {
        if (mode == 0) return;
        if (mode == 1) { //こうしないとiが入っちゃう
            mode++;
            render();
            return;
        }
        scope (exit) text = text.tail(LINE_NUM);

        if (ctrl && shift && key == KeyButton.Semicolon) {
            this.label.size *= 1.01;
        } else if (ctrl && shift && key == KeyButton.Minus) {
            this.label.size /= 1.01;
        } else if (ctrl && key == KeyButton.KeyC) {
            Core().getClipboard().set(lastOutput.to!dstring);
        } else if (key == KeyButton.Enter) {
            showInterpretResult();
        } else if (key == KeyButton.Up) {
            moveHistoryCursor(-1);
        } else if (key == KeyButton.Down) {
            moveHistoryCursor(+1);
        } else if (key == KeyButton.Escape) {
            off();
        } else if (key == KeyButton.Tab) {
            showCandidates();
        }
        super.handle(key);
    }

    private void moveHistoryCursor(int d) {
        if (historyCursor + d < 0) return;
        if (historyCursor + d >= history.length) return;

        historyCursor += d;

        text.back = history[historyCursor];

        cursor = cast(int)text.back.length;
    }

    private void showInterpretResult() {
        auto input = text.back;

        if (input.empty) return;

        pushHistory(input);

        auto output = interpret(input);
        show(output.split("\n"));
    }

    private void showCandidates() {
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

    void on() {
        this.mode = 1;
        this.cursor = 0;
        this.rect.visible = true;
        Core().preventCallback();
        debug Controller().available = false;
        Game.getMap().pause();
        text = [""];
    }

    private void off() {
        this.mode = 0;
        this.cursor = 0;
        this.rect.visible = false;
        Core().allowCallback();
        debug Controller().available = true;
        Game.getMap().resume();
        text = [""];
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

    protected override void render() {
        auto strs = text.dup;
        strs[0..$-1] = strs[0..$-1].map!(t => " "~t).join("\n");
        strs[$-1] = (mode==0?":":">" ~ strs[$-1][0..cursor] ~ "|" ~ strs[$-1][cursor..$]);
        super.render(strs);
    }

    private string interpret(string str) {
        auto tokens = (">" ~ str).splitter!(Yes.keepSeparators)(ctRegex!"[>=]").array;

        return new RootSelection().interpret(TokenList(tokens));
    }

    private Selectable[] candidates(string str) {
        auto tokens = (">" ~ str).splitter!(Yes.keepSeparators)(ctRegex!"[>=]").array;

        return new RootSelection().candidates(TokenList(tokens));
    }
}
