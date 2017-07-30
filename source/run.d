module Run;

import std.stdio, std.format, std.traits, std.conv, std.range, std.algorithm, std.array;
import examples;
import game.GameMain;
import plot.Main;

enum RunMode {
    Game,
    Basic,
    CameraControl,
    Gui,
    Material,
    Mouse,
    Text,
    NoGC,
    Plot
};

void run(RunMode mode, string[] args) {
    writeln("=".repeat(13).join ~ "RUN!" ~ "=".repeat(13).join);
    writeln([EnumMembers!(RunMode)].to!(string[]).map!(a => a == mode.to!string ? a ~ "(*)" : a).join(", \n"));
    writeln("=".repeat(30).join);
    final switch(mode) {
    case RunMode.Basic:
        basicExample();
        break;
    case RunMode.CameraControl:
        cameraControlExample();
        break;
    case RunMode.Gui:
        guiExample();
        break;
    case RunMode.Material:
        materialExample();
        break;
    case RunMode.Mouse:
        mouseExample();
        break;
    case RunMode.Text:
        textExample();
        break;
    case RunMode.Game:
        gameMain(args);
        break;
    case RunMode.NoGC:
        noGcExample();
        break;
    case RunMode.Plot:
        plotMain();
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
