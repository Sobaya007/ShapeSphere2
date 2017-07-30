module sbylib.utils.Array;

// source from here:https://wiki.dlang.org/Memory_Management
import core.stdc.stdlib;
import std.string;

struct Array(T) {
    private T* first;
    private size_t length;
    private size_t realLength;

    this(size_t length) {
        this.realLength = length;
        this.first = cast(T*)malloc(length * T.sizeof);
        this.length = length;
    }

    void destroy() {
        free(cast(void*)this.first);
    }

    void opOpAssign(string op)(T value) if (op == "~") {
        this.incLength(1);
        this[this.length-1] = value;
    }

    void opOpAssign(string op)(Array!T value) if (op == "~") {
        auto oldLength = this.length;
        this.incLength(value.length);
        foreach (i; 0..value.length) {
            this[oldLength + i] = value[i];
        }
    }

    ref T opIndex(size_t idx) {
        return this.first[idx];
    }

    bool empty() {
        return this.length == 0;
    }

    T front() {
        return this.first[0];
    }

    T popFront() {
        auto res = this.first[0];
        this.first = &this.first[1];
        this.length--;
        return res;
    }

    int opApply(int delegate(ref T) dg) {
        int result = 0;
        foreach (i; 0..this.length) {
            result = dg(this[i]);
            if (result) break;
        }
        return result;
    }

    void filter(string po)() {
        auto len = this.length;
        this.length = 0;
        foreach (i; 0..len) {
            auto a = this[i];
            if (!mixin(po)) continue;
            this[this.length++] = this[i];
        }
    }

    private void incLength(size_t length) {
        this.length += length;
        if (this.length > this.realLength) {
            this.realLength = this.length + 10;
            this.first = cast(T*)realloc(this.first, this.realLength * T.sizeof)[0..this.realLength];
        }
    }
}
