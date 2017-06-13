module sbylib.core.Process;

class Process {
    private const void delegate(Process) func;
    private bool _isAlive;

    this(const void delegate(Process) func) {
        this.func = func;
        this._isAlive = true;
    }

    package bool step() {
        this.func(this);
        return _isAlive;
    }

    void kill() {
        this._isAlive = false;
    }

    bool isAlive() {return isAlive;}
}
