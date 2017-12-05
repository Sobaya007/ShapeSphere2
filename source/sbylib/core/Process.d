module sbylib.core.Process;

import sbylib.utils.Logger;

class Process {
    private const void delegate(Process) func;
    private bool _isAlive;
    private uint frame;
    private string name;
    private TimeLogger logger;

    this(const void delegate(Process) func, string name) in {
        assert(func !is null);
    } body {
        this.func = func;
        this._isAlive = true;
        this.logger = new TimeLogger(name);
        this.name = name;
    }

    package(sbylib) bool step() {
        this.logger.start();
        this.func(this);
        this.logger.stop();
        this.frame++;
        return this._isAlive;
    }

    void kill() {
        this._isAlive = false;
    }

    bool isAlive() {return this._isAlive;}
    uint getFrame() {return this.frame;}
}
