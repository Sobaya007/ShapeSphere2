module sbylib.utils.Watcher;

import std.functional;

class Watch(T) {
    private T value;
    private IWatcher[] watchers;

    this(T init = T.init) {
        this.value = init;
    }

    void opAssign(T value) {
        this.value = value;
        foreach (watcher; watchers) {
            watcher.onChange();
        }
    }

    @property T get() {
        return value;
    }

    override string toString() {
        import std.conv;
        return this.get().to!string;
    }

    alias get this;
}

interface IWatcher {
    void onChange();
}

class Watcher(T) : IWatcher {

    private T value;
    private bool needsUpdate;
    private void delegate(ref T) defineFunc;
    private IWatcher[] watchers;

    this(T init = T.init) {
        this.value = init;
    }

    this(void delegate(ref T) defineFunc, T init = T.init) {
        this.defineFunc = defineFunc;
        this.value = init;
        this.needsUpdate = true;
    }

    void addWatch(S)(Watch!S watch) {
        watch.watchers ~= this;
    }

    void addWatch(S)(Watcher!S watcher) {
        watcher.watchers ~= this;
    }

    void setDefineFunc(void delegate(ref T) defineFunc) {
        this.defineFunc = defineFunc;
    }

    override void onChange() {
        this.needsUpdate = true;
        foreach (watcher; this.watchers) {
            watcher.onChange();
        }
    }

    const(T) get() {
        if (this.needsUpdate) {
            this.defineFunc(this.value);
            this.needsUpdate = false;
        }
        return this.value;
    }

    override string toString() {
        return this.get().toString();
    }

    alias get this;
}
