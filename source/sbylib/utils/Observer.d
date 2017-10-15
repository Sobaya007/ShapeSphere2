module sbylib.utils.Observer;

import std.functional;
import std.algorithm;
import sbylib;
import std.stdio;

interface IObserved {
    void capturedBy(IObserver);
    void releasedBy(IObserver);
}

class Observed(T) : IObserved {
    private T value;
    private IObserver[] observers;

    this(T init = T.init) {
        this.value = init;
    }

    T opAssign(T value) {
        this.value = value;
        foreach (observer; observers) {
            observer.onChange();
        }
        return this.value;
    }

    T opOpAssign(string op)(T value) {
        mixin("this.value " ~ op ~ "= value;");
        foreach (observer; observers) {
            observer.onChange();
        }
        return this.value;
    }

    ref auto opDispatch(string s, Args...)(Args args) {
        foreach (observer; observers) {
            observer.onChange();
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

    override void capturedBy(IObserver observer) {
        this.observers ~= observer;
    }

    override void releasedBy(IObserver observer) {
        this.observers = this.observers.remove!(o => o is observer);
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

interface IObserver {
    void onChange();
}

class Observer(T) : IObserver, IObserved {

    private T value;
    private bool needsUpdate;
    private void delegate(ref T) defineFunc;
    private IObserver[] observers;

    this(T init = T.init) {
        this.value = init;
    }

    this(void delegate(ref T) defineFunc, T init = T.init) {
        this.defineFunc = defineFunc;
        this.value = init;
        this.needsUpdate = true;
    }

    void capture(IObserved watch) {
        watch.capturedBy(this);
    }

    void release(IObserved watch) {
        watch.releasedBy(this);
    }

    void define(void delegate(ref T) defineFunc) {
        this.defineFunc = defineFunc;
    }

    override void onChange() {
        this.needsUpdate = true;
        foreach (observer; this.observers) {
            observer.onChange();
        }
    }

    override void capturedBy(IObserver observer) {
        this.observers ~= observer;
    }

    override void releasedBy(IObserver observer) {
        this.observers = this.observers.remove!(o => o is observer);
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

class Lazy(ReturnType,SavedType=ReturnType) : IObserver {

    private SavedType value;
    private bool needsUpdate;
    private ReturnType delegate() defineFunc;

    this(ReturnType delegate() defineFunc, IObserved[] args...) {
        this.defineFunc = defineFunc;
        this.needsUpdate = true;
        foreach (arg; args) {
            arg.capturedBy(this);
        }
    }

    this(SavedType initialValue, ReturnType delegate() defineFunc, IObserved[] args...) {
        this.value = initialValue;
        this(defineFunc, args);
    }

    ReturnType get() {
        if (this.needsUpdate) {
            import std.stdio;
            writeln("updated");
            this.value = this.defineFunc();
            this.needsUpdate = false;
        }
        return this.value;
    }

    override void onChange() {
        this.needsUpdate = true;
    }

    override string toString() {
        import std.conv;
        return this.get().to!string;
    }

    alias get this;
}

unittest {

    auto a = new Observed!uvec3(new uvec3("homo", vec3(0)));
    auto x = new Lazy!float(delegate () => a.x + a.y + a.z, a);
    auto y = new Lazy!float(delegate () => a.x + a.y + a.z); //Missing Observe

    assert(x + 1 == 1);
    assert(y + 1 == 1);
    a += vec3(1);
    assert(x + 4 == 7);
    assert(y + 4 != 7); // y dont know a's change

    a.y++;
    a.z = 3;
    assert(a.toString() == "Uniform[homo]: (1,2,3)");

    assert(x + 4 == 10);
}

