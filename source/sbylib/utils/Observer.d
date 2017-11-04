module sbylib.utils.Lazy;

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

    T opOpAssign(string op, S)(S value) {
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
        import std.meta;
        static if (staticIndexOf!(s, __traits(allMembers, T)) >= 0) {
            return mixin("this.value." ~ s);
        } else static if (__traits(hasMember, T, "opDispatch")) {
            return this.value.opDispatch!(s, Args)(args);
        } else static if (isCallable!(__traits(getMember, T, s))) {
            static if (is(ReturnType!(__traits(getMember, T, s)) == void)) {
                mixin("this.value." ~ s)(args);
            } else {
                return mixin("this.value." ~ s)(args);
            }
        } else {
            static assert(false);
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

    this(S)(S delegate() defineFunc, IObserved[] args...) {
        this(defineFunc, S.init, args);
    }

    this(S)(S delegate() defineFunc, S sinit, IObserved[] args...) {
        this((ref S s) {
                s = defineFunc();
        }, sinit, args);
    }

    this(S)(void delegate(ref S) defineFunc, S sinit, IObserved[] args...) {
        this.defineFunc = defineFunc;
        this.value = sinit;
        this.needsUpdate = true;
        foreach (arg; args) this.capture(arg);
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

    Lazy!(S) getLazy(S=T)() {
        return new Lazy!(S)(this);
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

class Lazy(Type) {

    alias Po = Type;
    private Type delegate() func;

    this(Type delegate() func) {
        this.func = func;
    }

    this(S)(Observer!S observer) {
        this.func = () => observer.get();
    }

    this(S)(S delegate() defineFunc, IObserved[] args...) {
        this(defineFunc, S.init, args);
    }

    this(S)(S delegate() defineFunc, S sinit, IObserved[] args...) {
        this((ref S s) {
                s = defineFunc();
        }, sinit, args);
    }

    this(S)(void delegate(ref S) defineFunc, S sinit, IObserved[] args...) {
        auto observer = new Observer!(S)(defineFunc, sinit, args);
        this.func = () => observer.get();
    }

    auto opUnary(string op)() {
        mixin("return " ~ op ~ "func();");
    }

    NewType opCast(NewType)() {
        return new Lazy!(NewType.Po)(() => func());
    }

    Type get() {
        return func();
    }

    override string toString() {
        import std.conv;
        return this.get().to!string;
    }

    alias get this;
}


unittest {

    auto a = new Observed!uvec3(new uvec3("homo", vec3(0)));
    auto x = new Observer!float(delegate () => a.x + a.y + a.z,a).getLazy();
    auto y = new Observer!float(delegate () => a.x + a.y + a.z).getLazy(); //Missing Observe

    assert(x + 1 == 1);
    assert(y + 1 == 1);
    a += vec3(1);
    assert(x + 4 == 7);
    assert(y + 4 != 7); // y dont know a's change

    a.y++;
    a.z = 3;
    a *= 2;
    assert(a.toString() == "Uniform[homo]: (2,4,6)");
    assert(x + 4 == 16);

    auto b = new Observed!vec3(vec3(1));

    b *= 2;

    assert(b.x == 2);
}

