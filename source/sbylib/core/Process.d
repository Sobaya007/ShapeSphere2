module sbylib.core.Process;

class Process {
    private const void delegate(Process) func;
    private bool _isAlive;

    this(const void delegate(Process) func) {
        this.func = func;
        this._isAlive = true;
    }

    void step() {
        this.func(this);
    }

    void kill() {
        this._isAlive = false;
    }

    bool isAlive() {return isAlive;}
}
