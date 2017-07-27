module game.command.CommandList;

import std.file;
import game.command.Command;
import game.command.CommandSpawner;

class CommandList {
    private Command[] commands;
    private CommandSpawner[] spawners;

    this(CommandSpawner[] spawners) {
        this.spawners = spawners;
    }

    void update() {
        foreach (spawner; this.spawners) {
            if (auto command = spawner.spawn()) {
                command.act();
                commands ~= command;
            }
        }
    }

    void play() {
        foreach (c; this.commands) {
            c.act();
        }
    }
}
