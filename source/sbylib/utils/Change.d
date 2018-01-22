module sbylib.utils.Change;

mixin template ImplChangeCallback() {
    private void delegate()[] callbacks;

    void delegate() addChangeCallback(void delegate() cb) {
        this.callbacks ~= cb;
        import std.algorithm;
        return {
            this.callbacks.remove!(c => c == cb);
        };
    }

    private void onChange() {
        foreach (cb; this.callbacks) {
            cb();
        }
    }
}

struct ChangeObserveTarget(T) {
    const(T) delegate() get;
    void delegate() delegate(void delegate()) addChangeCallback;
    void delegate() onChange;

    const(T) get2() {
        return this.get();
    }

    alias get2 this;
}

struct ChangeObservedArray(T) {
    import std.traits;

    private T[] array;
    private const(T) delegate()[] getters;
    private bool[] needsUpdate;

    this(S)(S[] array) {
        this.array.length = array.length;
        this.needsUpdate.length = array.length;
        foreach (i, ch; array) {
            (j, c) {
                c.addChangeCallback({
                    if (this.needsUpdate[j]) return;
                    this.needsUpdate[j] = true;
                    this.onChange();
                });
                static if (isPointer!(typeof(&c.get))) {
                    this.getters ~= c.get;
                } else {
                    this.getters ~= &c.get;
                }
            }(i, ch);
        }
        this.needsUpdate[] = true;
    }

    const(const(T)[]) get() {
        foreach (i, ref u; this.needsUpdate) {
            if (!u) continue;
            u = false;
            this.array[i] = cast(T)this.getters[i]();
        }
        return this.array;
    }

    ChangeObserveTarget!(T[]) getTarget() {
        return ChangeObserveTarget!(T[])(&this.get, &this.addChangeCallback, &this.onChange);
    }

    mixin ImplChangeCallback;
}

struct ChangeObserved(T) {
    import std.traits;
    alias Type = Unqual!T;
    private Type value;

    this(Type value) {
        this.value = value;
    }

    this(Type value, void delegate()[] onChange) {
        this.value = value;
        this.callbacks = onChange;
    }

    @disable this(this);

    invariant {
        static if (isPointer!Type
                || is(Type == class)
                || is(Type == function)
                || is(Type == delegate)) {
            assert(this.value !is null);
        }
    }

    static if (isPointer!Type) {
        alias CoreType = PointerTarget!(Type);
    } else {
        alias CoreType = Type;
    }

    mixin ImplChangeCallback;

    static if (isAggregateType!(CoreType)
            && __traits(getAliasThis, CoreType).length == 1
            && isCallable!(mixin("value." ~ __traits(getAliasThis, CoreType)[0]))
                && is(typeof(mixin("value." ~ __traits(getAliasThis, CoreType)[0])) R == return)) {
        enum Member = "value." ~ __traits(getAliasThis, CoreType)[0];

        enum isConst = hasFunctionAttributes!(mixin(Member), "const");

        const(Unqual!R) get() in {
            static if (is(typeof(this.value is null))) {
                assert(this.value !is null);
            }
        } body {
            auto r = mixin(Member ~ "()");
            static if (isConst) this.onChange();
            return r;
        }
    } else {
        const(CoreType) get() const {
            return mixin(Value);
        }
    }

    alias get this;

    void set(ArgType)(ArgType value) if (isAssignable!(Type, ArgType)) {
        this.value = value;
        this.onChange();
    }

    void opAssign(ArgType)(ArgType value) if (isAssignable!(Type, ArgType)) {
        this.value = value;
        this.onChange();
    }

    const(CoreType) opOpAssign(string op, Type2)(Type2 value) {
        auto result = mixin(Value ~ op ~ "= value");
        this.onChange();
        return result;
    }

    void opIndexAssign(Type2)(Type2 value, size_t i) {
        this.value[i] = value;
        this.onChange();
    }

    bool opEquals(ArgType)(ref ArgType arg) {
        return this.value == arg;
    }

    bool opEquals(ArgType)(ArgType arg) {
        return this.value == arg;
    }
    enum Value = isPointer!(T) ? "*this.value" : "this.value";

    auto opBinary(string op, ArgType)(ref ArgType arg) {
        return mixin(Value ~ op ~ " arg");
    }

    auto opBinaryRight(string op, ArgType)(ref ArgType arg) {
        return mixin("arg " ~ op ~ Value);
    }

    auto opUnary(string op)() {
        auto r = mixin(op ~ "this.value");
        static if (op == "++" || op == "--") this.onChange();
        return r;
    }

    template haveMember(Type, string member) {
        import std.meta;
        static if (isAggregateType!Type) {
            static if (Filter!(ApplyLeft!(isSame, member), __traits(allMembers, Type)).length > 0) {
                enum haveMember = true;
            } else static if (is(typeof({Type t; auto po = &t.opDispatch!(member);}))) {
                enum haveMember = true;
            } else static if (isAggregateType!Type && __traits(getAliasThis, Type).length > 0) {
                enum This = "Type." ~ __traits(getAliasThis, Type)[0];
                static if (isCallable!(mixin(This))) {
                    alias Type2 = ReturnType!(mixin(This));
                } else {
                    alias Type2 = typeof(mixin(This));
                }
                enum haveMember = haveMember!(Type2, member);
            } else {
                enum haveMember = false;
            }
        } else static if (isArray!Type) {
            enum haveMember = member == "length";
        } else {
            enum haveMember = false;
        }
    }

    template opDispatch(string member) if (haveMember!(CoreType, member)) {
        enum Member = "value." ~ member;
        static if (is(typeof(isCallable!(mixin(Member)))) && isCallable!(mixin(Member))) {
            alias R = ReturnType!(mixin(Member));
            alias isConst = hasFunctionAttributes!(mixin(Member), "const");
            alias isRef = hasFunctionAttributes!(mixin(Member), "ref");
            static assert(!isRef);
            static if (is(R == void)) {
                void opDispatch(Args...)(Args args) {
                    mixin(Member ~ "(args);");
                    static if (!isConst) this.onChange();
                }
            } else {
                ChangeObserved!R opDispatch(Args...)(Args args) {
                    auto result = mixin(Member ~ "(args)");
                    static if (!isConst) this.onChange();
                    return ChangeObserved!R(result, this.callbacks);
                }
            }
        } else {
            static if (is(typeof(mixin(Member)) T)) {
                static if (is(typeof(&mixin(Member)))) {
                    ChangeObserved!(T*) opDispatch() {
                        return ChangeObserved!(T*)(&mixin(Member), this.callbacks);
                    }
                } else {
                    ChangeObserved!(T) opDispatch() {
                        return ChangeObserved!(T)(mixin(Member), this.callbacks);
                    }
                }

                ChangeObserved!T opDispatch(Arg)(Arg arg) {
                    auto result = mixin(Member ~ " = arg");
                    this.onChange();
                    return ChangeObserved!T(result, this.callbacks);
                }
            } else {
                // some template function?
                auto opDispatch(Args...)(ref Args args) if (is(typeof(mixin(Member ~ "(args)")))) {
                    enum InstancedMember = Member ~ "!(Args)";
                    alias R = ReturnType!(mixin(InstancedMember));
                    alias isConst = hasFunctionAttributes!(mixin(InstancedMember), "const");
                    alias isRef = hasFunctionAttributes!(mixin(InstancedMember), "ref");
                    static assert(!isRef);
                    static if (is(R == void)) {
                        mixin(InstancedMember ~ "(args);");
                        static if (!isConst) this.onChange();
                    } else {
                        auto result = mixin(InstancedMember ~ "(args)");
                        static if (!isConst) this.onChange();
                        return ChangeObserved!R(result, this.callbacks);
                    }
                }
            }
        }
    }

    string toString() {
        import std.conv;
        return to!string(this.value);
    }

    ChangeObserveTarget!(Unqual!(ReturnType!(this.get))) getTarget() {
        return ChangeObserveTarget!(Unqual!(ReturnType!(this.get)))(&this.get, &this.addChangeCallback, &this.onChange);
    }
}


import std.traits, std.meta;
struct Depends(alias Function, Type = ReturnType!Function) {

    alias Args = Parameters!Function;

    alias Getter(Type) = const(Type) delegate();
    alias Views = staticMap!(Getter, Args);

    private Type value;
    private Type delegate(Args) func;
    private Views views;
    private void delegate()[Args.length] removers;
    private bool needsUpdate;
    bool initialized;

    this(Type initial) {
        this.value = initial;
        this.needsUpdate = true;
        this.initialized = false;
    }

    @disable this(this);

    mixin ImplChangeCallback;

    enum canAccept(Type) = is(typeof(Type.init.getTarget));

    void depends(Dependency...)(ref Dependency dependency) if (Dependency.length == Args.length && allSatisfy!(canAccept, Dependency)) {
        if (this.initialized) this.clearDependency();
        foreach (i, ref v; dependency) {
            this.views[i] = () => cast(const(Args[i]))v.get();
            this.removers[i] = v.addChangeCallback(&this.notify);
        }
        this.needsUpdate = true;
        this.initialized = true;
        this.onChange();
    }

    const(Type) get()  in {
        assert(this.initialized, "You must call 'depends' before use of this.");
    } body {
        if (this.needsUpdate) {
            this.needsUpdate = false;
            import std.algorithm, std.range, std.format;
            this.value = mixin(format!"Function(%s)"(iota(Views.length).map!(i => format!"this.views[%d]()"(i)).join(",")));
        }
        return this.value;
    }

    alias get this;

    void notify() in {
        assert(this.initialized, "You must call 'depends' before use of this.");
    } body {
        if (this.needsUpdate) return;
        this.needsUpdate = true;
        this.onChange();
    }

    ChangeObserveTarget!(Unqual!(ReturnType!(this.get))) getTarget() {
        return ChangeObserveTarget!(Unqual!(ReturnType!(this.get)))(&this.get, &this.addChangeCallback, &this.onChange);
    }

    string toString() {
        import std.conv;
        return this.get().to!string;
    }

    private void clearDependency() {
        foreach (remove; this.removers) {
            remove();
        }
    }
}

unittest {
    {
        ChangeObserved!int x;
        ChangeObserved!int y;
        Depends!((int x, int y) => x + y) sum;
        Depends!((int x, int y) => x - y) sub;

        sum.depends(x, y);
        sub.depends(x, y);

        ()  {
            x = 3;
            y = 2;
            assert(x == 3);
            assert(y == 2);
            assert(sum == 5);
            assert(sub == 1);

            y += 2;
            assert(y == 4);
            assert(sum == 7);
            assert(sub == -1);
        }();
    }

    {
        import std.algorithm;
        ChangeObserved!(int[]) arr;
        Depends!((const(int[]) arr) => arr.sum) sum;
        sum.depends(arr);
        arr ~= 3;
        arr ~= 4;
        arr ~= 5;
        assert(sum == 12);
        arr ~= 6;
        assert(sum == 18);
        arr = (int[]).init;
        assert(sum == 0);
    }

    {
        import sbylib.math.Vector;
        auto v = ChangeObserved!vec2(vec2(3, 4));
        Depends!((const vec2 v) => v.length) len;
        len.depends(v);

        assert(len == 5);

        v.y = 0;

        assert(len == 3);
    }

}
