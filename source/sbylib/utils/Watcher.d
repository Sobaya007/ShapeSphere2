module sbylib.utils.Watcher;

import std.functional;

class Watch(T) {
    private T value;
    private IWatcher[] watchers;

    this() {
    }

    void opAssign(T value) {
        this.value = value;
        foreach (watcher; watchers) {
            watcher.onChange();
        }
    }

   @property immutable(T) get() {
        return value;
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

    this(void delegate(ref T) defineFunc, T init = T.init) {
        this.defineFunc = defineFunc;
        this.value = init;
    }

    void addWatch(S)(Watch!S watch) {
        watch.watchers ~= this;
    }

    void addWatch(S)(Watcher!S watcher) {
        watcher.watchers ~= this;
    }

    override void onChange() {
        this.needsUpdate = true;
        foreach (watcher; this.watchers) {
            watcher.onChange();
        }
    }

    immutable(T) get() {
        if (this.needsUpdate) {
            this.defineFunc(this.value);
            this.needsUpdate = false;
        }
        return cast(immutable)(this.value);
    }

    alias get this;
}
