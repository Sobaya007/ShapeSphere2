module game.command.Command;

class Command {
    private void delegate() action;

    this(void delegate() action) {
        this.action = action;
    }

    void act() {
        this.action();
    }
}
