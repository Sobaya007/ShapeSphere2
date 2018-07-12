module entry;

import std.stdio, std.format, std.traits, std.conv, std.range, std.algorithm, std.array;
import examples;
import game.GameMain;

enum RunMode {
    Basic,
    XFileLoad,
    Material,
    Framebuffer,
    Stencil,
    Blits,
    Text,
    Clipboard,
    Gui,
    Game,
    Scene,
};

void run(string[] args) {
    import sbylib;
    auto universe = Universe.createFromJson(ResourcePath("world/entry.json"));
    auto world = universe.getWorld("world").unwrap();
    auto factory = LabelFactory();
    factory.height = 40;
    factory.strategy = Label.Strategy.Left;
    
    enum ModeList = [EnumMembers!(RunMode)];
    auto selection = new Selection!(Label)(SelectionStrategy.Repeat);
    foreach (i, mode; ModeList) {
        factory.text = format!"%s%s"(i==0 ? ">" : "", ModeList[i].to!string).to!dstring;
        auto label = factory.make();
        world.add(label);
        label.left = -Core().getWindow().width/2 + 30;
        label.top = i * -factory.height + ModeList.length * factory.height * 0.5;
        label.setUserData("mode", mode);
        auto handler = selection.register(label);
        handler.onFocusIn.add((Label label) {
            label.renderText(format!">%s"(label.getUserData!(RunMode)("mode").unwrap()));
        });
        handler.onFocusOut.add((Label label) {
            label.renderText(format!"%s"(label.getUserData!(RunMode)("mode").unwrap()));
        });
        handler.onSelect.add((Label label) {
            universe.destroy();
            run(label.getUserData!(RunMode)("mode").unwrap(), args);
        });
    }
    universe.justPressed(KeyButton.Up).add(&selection.prev);
    universe.justPressed(KeyButton.Down).add(&selection.next);
    universe.justPressed(KeyButton.Enter).add(&selection.select);
    Core().start();
}

void run(RunMode mode, string[] args) {
    writeln("=".repeat(13).join ~ "RUN!" ~ "=".repeat(13).join);
    writeln([EnumMembers!(RunMode)].to!(string[]).map!(a => a == mode.to!string ? a ~ "(*)" : a).join(", \n"));
    writeln("=".repeat(30).join);
    final switch(mode) {
    case RunMode.Basic:
        basicExample();
        break;
    case RunMode.Gui:
        guiExample();
        break;
    case RunMode.Material:
        materialExample();
        break;
    case RunMode.Text:
        textExample();
        break;
    case RunMode.Clipboard:
        clipboardExample();
        break;
    case RunMode.Game:
        gameMain(args);
        break;
    case RunMode.XFileLoad:
        xFileLoadExample();
        break;
    case RunMode.Scene:
        sceneExample(args);
        break;
    case RunMode.Framebuffer:
        framebufferExample();
        break;
    case RunMode.Blits:
        blitsExample();
        break;
    case RunMode.Stencil:
        stencilExample();
        break;
    }
}

void showHelp() {
    writeln("=".repeat(13).join, "HELP", "=".repeat(13).join);
    writeln("Usege: dub [--mode={mode}] [--history={history}] [--replay={history}]");
    auto commands = [EnumMembers!(RunMode)].to!(string[]);
    commands[0] ~= " (Deafault)";
    writeln(format!"{mode} =\n\t%s"(commands.join(", \n\t")));
    writeln(`
"--history" and "--replay" can only be used in Game mode.;
{history} = history file save path.(Default = "history/replayXX.history"
{replay} = history file save path.
if you use "--replay=latest", use latest history file in "history/replayXX.history"`);
    writeln("=".repeat(30).join);
}
