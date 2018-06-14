module sbylib.core.Process;

import sbylib.utils.Logger;
import sbylib.utils.TimeCounter;

class Process {
    private const void delegate(Process) func;
    private bool _isAlive;
    private uint frame;
    string name;

    private debug TimeCounter!100 counter;

    this(const void delegate(Process) func, string name) in {
        assert(func !is null);
    } body {
        this.func = func;
        this._isAlive = true;
        this.name = name;
        debug this.counter = new TimeCounter!100;
    }

    this(const void delegate(Process) func, string name = __FILE__, int line = __LINE__) in {
        assert(func !is null);
    } body {
        this(func, name ~ line.stringof);
    }

    package(sbylib) bool step() in {
        assert(isAlive);
    } do {
        debug this.counter.start();
        this.func(this);
        this.frame++;
        debug this.counter.stop();
        return this._isAlive;
    }

    void kill() {
        this._isAlive = false;
    }

    debug auto averageTime() {
        return this.counter.averageTime;
    }

    bool isAlive() {return this._isAlive;}
    uint getFrame() {return this.frame;}
}
