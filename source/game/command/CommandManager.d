module game.command.CommandManager;

import std.file, std.algorithm, std.range, std.array;
import game.command.Command;

private ubyte CommandVersion = 1; //When you update format of command, you must change this value.

interface ICommandManager {
    void addCommand(ICommand);
    void update();
    void save();
    bool isPlaying();
}

class PlayCommandManager : ICommandManager {
    private ubyte[] history;
    private string writeFilePath;
    private ICommand[] commands;

    this(string writeFilePath) {
        this.history = [CommandVersion];
        this.writeFilePath = writeFilePath;
    }

    override void addCommand(ICommand command) {
        this.commands ~= command;
    }

    override void update() {
        foreach (cmd; this.commands) {
            cmd.act();
            this.history ~= cmd.value;
        }
    }

    override void save() {
        std.file.write(this.writeFilePath, this.history);
    }

    override bool isPlaying() {
        return false;
    }

}

class ReplayCommandManager : ICommandManager {
    private ICommand[] commands;
    private ubyte[] inputHistory;
    private ubyte[] outputHistory;
    private string writeFilePath;
    private bool playing;

    this(string readFilePath, string writeFilePath) {
        this.writeFilePath = writeFilePath;
        this.inputHistory = this.loadData(readFilePath);
        this.outputHistory = [CommandVersion];
        this.playing = true;
    }

    override void addCommand(ICommand command) {
        this.commands ~= command;
    }

    override void update() {
        if (this.playing) {
            foreach (i, cmd; this.commands) {
                cmd.replay(this.inputHistory);
                this.outputHistory ~= cmd.value;
            }
            if (this.inputHistory.length == 0) this.playing = false;
        } else {
            foreach (cmd; this.commands) {
                cmd.act();
                this.outputHistory ~= cmd.value;
            }
        }
    }

    override void save() {
        std.file.write(this.writeFilePath, this.outputHistory);
    }

    override bool isPlaying() {
        return this.playing;
    }


    private ubyte[] loadData(string path) {
        auto rowData = cast(ubyte[])std.file.read(path);
        auto versionData = rowData[0];
        assert(versionData == CommandVersion);
        return rowData[1..$];
    }
}
