module sbylib.core.Process;

import sbylib.utils.Logger;
import sbylib.utils.TimeCounter;

class ProcessManager {

    import sbylib.utils.Array;

    private Array!Process processes;

    this() {
        this.processes = Array!Process(0);
    }

    ~this() {
        processes.destroy();
    }

    void update() {
        synchronized(this) {
            import std.algorithm : all;
            assert(this.processes.all!(proc => proc.isAlive()));
            this.processes.filter!(proc => proc.isAlive() && proc.step());
            assert(this.processes.all!(proc => proc.isAlive()));
        }
    }

    Process addProcess(const void delegate(Process) func, string name) {
        auto proc = new Process(func, name);
        synchronized(this) {
            this.processes ~= proc;
        }
        return proc;
    }

    Process addProcess(const void delegate() func, string name) {
        return this.addProcess((Process proc) {
            func();
        }, name);
    }

    Process addProcess(const void function() func, string name) {
        return this.addProcess((Process proc) {
            func();
        }, name);
    }

    /*
    ref Array!Process allProcess() {
        return processes;
    }
    */

    auto opDispatch(string mem)() {
        foreach (proc; processes) {
            mixin("proc."~mem~"();");
        }
    }
}

class Process {
    private const void delegate(Process) func;
    private bool alive;
    private bool paused;
    private uint frame;
    string name;

    private debug TimeCounter!100 counter;

    this(const void delegate() func, string name) {
        this((Process proc) { func(); }, name);
    }

    this(const void delegate(Process) func, string name)
        in(func !is null)
    {
        this.func = func;
        this.alive = true;
        this.paused = false;
        this.name = name;
        debug this.counter = new TimeCounter!100;
    }

    this(const void delegate(Process) func, string name = __FILE__, int line = __LINE__) {
        this(func, name ~ line.stringof);
    }

    ~this() {
    }

    debug void appendLog() {
        import std.file, std.format;
        enum FILE = "process.log";
        append(FILE, format!"%s: %.2f\n"(this.name, this.averageTime));
    }

    package(sbylib) bool step()
        in(this.isAlive, this.name)
    {
        if (!paused) {
            debug this.counter.start();
            this.func(this);
            this.frame++;
            debug this.counter.stop();
        }
        return this.alive;
    }

    void kill()
        in(this.isAlive)
    {
        this.alive = false;
    }

    void pause()
        in(!this.isPaused)
    {
        this.paused = true;
    }

    void resume()
        in(this.isPaused)
    {
        this.paused = false;
    }

    debug auto averageTime() {
        return this.counter.averageTime;
    }

    bool isAlive() {return this.alive;}
    bool isPaused() {return this.paused;}
    uint getFrame() {return this.frame;}
}
