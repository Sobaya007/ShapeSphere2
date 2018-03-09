module sbylib.core.Process;

import sbylib.utils.Logger;

class Process {
    private const void delegate(Process) func;
    private bool _isAlive;
    private uint frame;
    private string name;

    this(const void delegate(Process) func, string name) in {
        assert(func !is null);
    } body {
        this.func = func;
        this._isAlive = true;
        this.name = name;
    }

    this(const void delegate(Process) func, string name = __FILE__, int line = __LINE__) in {
        assert(func !is null);
    } body {
        this(func, name ~ line.stringof);
    }

    package(sbylib) bool step() {
        this.func(this);
        this.frame++;
        return this._isAlive;
    }

    void kill() {
        this._isAlive = false;
    }

    bool isAlive() {return this._isAlive;}
    uint getFrame() {return this.frame;}
}
