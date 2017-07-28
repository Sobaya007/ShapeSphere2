module game.command.CommandSpawner;

import game.command.Command;

class CommandSpawner {

    private Command command;
    private bool delegate() cond;

    this(bool delegate() cond, Command command) {
        this.cond = cond;
        this.command = command;
    }

    Command spawn() {
        return this.cond() ? this.command : null;
    }

    Command getCommand() {
        return this.command;
    }
}
