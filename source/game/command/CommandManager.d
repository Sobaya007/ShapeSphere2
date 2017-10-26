module game.command.CommandManager;

import std.file, std.algorithm, std.range, std.array;
import game.command.Command;
import game.command.CommandSpawner;

class CommandManager {
    private Command[][] commands;
    private CommandSpawner[] spawners;
    private string writeFilePath;
    private bool play;

    import std.stdio;

    this(string writeFilePath) {
        this.spawners = spawners;
        this.writeFilePath = writeFilePath;
    }

    this(string readFilePath, string writeFilePath) {
        this(writeFilePath);
        this.play = true;
        this.commands = this.loadData(readFilePath);
    }

    void addSpawner(CommandSpawner spawner) {
        this.spawners ~= spawner;
    }

    void update() {
        if (this.play) {
            this.replay();
        } else {
            this.normalUpdate();
        }
    }

    void save() {
        auto original = this.spawners.map!(s => s.getCommand()).array;
        auto data = this.commands.map!(cs => cs.map!(c => cast(byte)original.countUntil(c)).array).join(cast(byte)-1);
        std.file.write(this.writeFilePath, data);
    }

    bool isPlaying() {
        return this.play;
    }

    private void normalUpdate() {
        Command[] commands;
        foreach (spawner; this.spawners) {
            if (auto command = spawner.spawn()) {
                command.act();
                commands ~= command;
            }
        }
        this.commands ~= commands;
    }

    private void replay() {
        if (this.commands.length == 0) {
            this.play = false;
            this.normalUpdate();
            return;
        }
        foreach (command; this.commands[0]) {
            command.act();
        }
        this.commands = this.commands[1..$];
    }

    private Command[][] loadData(string path) {
        auto original = this.spawners.map!(s => s.getCommand()).array;
        byte[] data = cast(byte[])std.file.read(path);
        return data.split(cast(byte)-1).map!(bs => bs.map!(b => original[b]).array).array;
    }
}
