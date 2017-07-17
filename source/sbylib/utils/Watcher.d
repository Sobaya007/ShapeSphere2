module sbylib.utils.Watcher;

import std.functional;
import std.algorithm;
import sbylib;

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

    void opOpAssign(string op)(T value) {
        mixin("this.value " ~ op ~ "= value;");
        foreach (watcher; watchers) {
            watcher.onChange();
        }
    }

    ref auto opDispatch(string s, Args...)(Args args) {
        foreach (watcher; watchers) {
            watcher.onChange();
        }
        import std.traits;
        static if (__traits(hasMember, T, "opDispatch")) {
            return this.value.opDispatch!(s, Args)(args);
        } else static if (isCallable!(__traits(getMember, T, s))) {
            static if (is(ReturnType!(__traits(getMember, T, s)) == void)) {
                mixin("this.value." ~ s)(args);
            } else {
                return mixin("this.value." ~ s)(args);
            }
        } else {
            return mixin("this.value." ~ s);
        }
    }

    override string toString() {
        import std.conv;
        return this.get().to!string;
    }

    T get() {
        return this.value;
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

    void removeWatch(S)(Watch!S watch) {
        watch.watchers = watch.watchers.remove!(w => w == this);
    }

    void removeWatch(S)(Watcher!S watcher) {
        watcher.watchers = watcher.watchers.remove!(w => w == this);
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

    T get() {
        if (this.needsUpdate) {
            this.defineFunc(this.value);
            this.needsUpdate = false;
        }
        return this.value;
    }

    override string toString() {
        import std.conv;
        return this.get().to!string;
    }

    alias get this;
}
