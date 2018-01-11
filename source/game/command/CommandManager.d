module game.command.CommandManager;

import std.file, std.algorithm, std.range, std.array;
import game.command.Command;
import sbylib;

private ubyte CommandVersion = 1; //When you update format of command, you must change this value.

interface ICommandManager {
    void setReceiver(CommandReceiver);
    void update();
    void save();
    bool isPlaying();
}

class CommandReceiver {
    package ICommand[] commands;

    void addCommand(ICommand command) {
        this.commands ~= command;
    }

    package void act(ubyte[] history) {
        foreach (cmd; this.commands) {
            cmd.act();
            history ~= cmd.value;
        }
    }

    package void replay(ref ubyte[] input, ubyte[] output) {
        foreach (cmd; this.commands) {
            cmd.replay(input);
            output ~= cmd.value;
        }
    }
}

class PlayCommandManager : ICommandManager {
    private ubyte[] history;
    private string writeFilePath;
    private CommandReceiver receiver;

    this(string writeFilePath) {
        this.history = [CommandVersion];
        this.writeFilePath = writeFilePath;
    }

    override void setReceiver(CommandReceiver receiver) {
        this.receiver = receiver;
    }

    override void update() {
        this.receiver.act(this.history);
    }

    override void save() {
        std.file.write(this.writeFilePath, this.history);
    }

    override bool isPlaying() {
        return false;
    }

}

class ReplayCommandManager : ICommandManager {
    private CommandReceiver receiver;
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

    override void setReceiver(CommandReceiver receiver) {
        this.receiver = receiver;
    }

    override void update() {
        if (this.playing) {
            this.receiver.replay(this.inputHistory, this.outputHistory);
            if (this.inputHistory.length == 0) this.playing = false;
        } else {
            this.receiver.act(this.outputHistory);
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
