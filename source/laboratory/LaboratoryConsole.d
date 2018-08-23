module laboratory.LaboratoryConsole;

import sbylib;
import laboratory.Interpreter;

class LaboratoryConsole : Console {

    alias DEFAULT_COLOR = (string str) => str.colored(vec3(1));
    alias PERFORMING_COLOR = (string str) => str.colored(vec3(0.5, 0.5, 1));
    alias DEFAULT_DISABLED_COLOR = (string str) => str.colored(vec3(0.8));
    alias WAIT_COLOR = (string str) => str.colored(vec3(0));
    alias CANDIDATES_COLOR = (string str) => str.colored(vec3(1,1, 0.4));
    alias WARNING_COLOR = (string str) => str.colored(vec3(1,0.2, 0.2));

    private int mode = 0;
    private enum LINE_NUM = 30;
    private string[] history;
    private int historyCursor;
    private Interpreter interpreter;
    private Maybe!Performer performer;

    private string[] lastCandidates; // for avoiding duplicate show

    alias rect this;

    this(World target) {
        super();

        this.pos.z = 0.5;
        this.off();

        this.interpreter = new Interpreter(this, target);
    }

    static add(World targetWorld) {
        auto world = new World;
        auto renderer = createRenderer2D(world, Core().getWindow().getScreen());
        auto console = new LaboratoryConsole(targetWorld);
        world.add(console);
        Core().addProcess({
            Core().getWindow().getScreen().clear(ClearMode.Depth);
            renderer.renderAll();
        }, "console render");
        return console;
    }

    protected override void handle(KeyButton key) {
        import std.range : tail;
        if (mode == 0) return;
        if (mode == 1) { //こうしないとiが入っちゃう
            mode++;
            renderForConsole();
            return;
        }
        scope (exit) text = text.tail(LINE_NUM);

        if (ctrl && shift && key == KeyButton.Semicolon) {
            this.label.size *= 1.01;
        } else if (ctrl && shift && key == KeyButton.Minus) {
            this.label.size /= 1.01;
        } else if (ctrl && key == KeyButton.KeyC) {
            if (this.performer.isJust) {
                cancelPerform();
                show(WARNING_COLOR("perform canceled"));
            }
        } else if (key == KeyButton.Enter) {
            onEnter();
        } else if (key == KeyButton.Up) {
            moveHistoryCursor(-1);
        } else if (key == KeyButton.Down) {
            moveHistoryCursor(+1);
        } else if (key == KeyButton.Escape) {
            off();
        } else if (key == KeyButton.Tab) {
            showCandidates();
        } else {
            super.handle(key);
        }
    }

    private void moveHistoryCursor(int d) {
        if (historyCursor + d < 0) return;
        if (historyCursor + d >= history.length) return;

        historyCursor += d;

        this.inputString = history[historyCursor];

        cursor = cast(int)this.inputString.length;
    }

    private void onEnter() {
        if (performer.isJust) {
            stepPerformer(this.inputString);
        } else {
            interpret();
        }
        this.inputString = "";
        this.cursor = 0;
    }

    void stepPerformer() {
        this.performer = performer.unwrap().step("");
        this.renderForConsole();
    }

    private void stepPerformer(string input) {
        show(input);
        this.performer = performer.unwrap().step(input);
    }

    private void interpret() {
        import std.array : empty;
        import std.string : split;

        auto input = this.inputString;

        if (input.empty) return;

        show(input);

        pushHistory(input);

        this.performer = interpreter.interpret(input);
    }

    void on() {
        this.mode = 1;
        this.cursor = 0;
        this.rect.visible = true;
        Core().getWindow().key.preventCallback();
        this.inputString = "";
        text = [WHITE("")];
    }

    private void off() {
        this.mode = 0;
        this.cursor = 0;
        this.rect.visible = false;
        if (this.performer.isJust) this.cancelPerform();
        Core().getWindow().key.allowCallback();
        this.inputString = "";
        text = [WHITE("")];
        this.lastCandidates = [];
    }

    void show(string str) {
        return show([str]);
    }

    void show(ColoredString str) {
        return show([str]);
    }

    void show(string[] strs) {
        import std.algorithm : map;
        import std.array : array;
        show(strs.map!(s => DEFAULT_DISABLED_COLOR(s)).array);
    }

    void show(ColoredString[] strs) {
        import std.algorithm : map;
        import std.array : array, join;

        enum MAX_LENGTH = 40;
        text ~= strs
            .map!(s => s.length < MAX_LENGTH ? s : ColoredString(s[0..MAX_LENGTH/2])~"..."~ColoredString(s[$-MAX_LENGTH/2-3..$]))
            .map!(s => ColoredString(s))
            .array;
        text ~= WHITE("");
        cursor = 0;
    }

    string getInput() {
        return inputString;
    }

    private void pushHistory(string command) {
        import std.array : empty;
        if (command.empty) return;
        history ~= command;
        historyCursor = cast(int)history.length;
    }

    protected override void renderForConsole() {
        import std.algorithm : map;
        import std.array : array;

        if (this.mode == 0) {
            super.render([WAIT_COLOR(":")]);
        } else {
            auto strs = text.dup;
            strs = strs.map!(t => ColoredString(DEFAULT_COLOR(" ")~t)).array;
            auto lastLine  = (inputString[0..cursor] ~ "|" ~ inputString[cursor..$]);
            auto coloredInput = interpreter.isCorrectInput(inputString) ? DEFAULT_COLOR(lastLine) : WARNING_COLOR(lastLine);
            auto prefix = performer.isJust ? PERFORMING_COLOR(">") : DEFAULT_COLOR(">");
            auto coloredLastLine = ColoredString(prefix ~ coloredInput);
            super.render(strs ~ coloredLastLine);
        }
    }

    private void showCandidates() {
        if (this.inputString.length == 0) {
            import std.algorithm : map;
            import std.array : array;

            auto candidates = this.interpreter.getCandidates();
            if (lastCandidates == candidates) return;
            lastCandidates = candidates;
            show(candidates
                .map!(s => CANDIDATES_COLOR(s))
                .array);
            return;
        }
        auto output = this.interpreter.complete(this.inputString);
        if (output.isJust) {
            this.inputString = output.unwrap();
            this.cursor = cast(int)this.inputString.length;
        }
    }

    private void cancelPerform() {
        this.performer.stop();
        this.performer = None!(Performer);
    }
}
