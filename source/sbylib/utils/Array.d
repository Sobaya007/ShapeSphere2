module sbylib.utils.Array;

// source from here:https://wiki.dlang.org/Memory_Management
import core.stdc.stdlib;
import core.memory;
import std.string;

struct Array(T) {
    private T* ptr;
    private size_t _length;
    private size_t realLength;
    private bool valid;

    private enum invalidMessage = "This array is invalid.(before initialize or after destroy)";

    this(size_t capacity) out {
        assert(this.ptr);
    } body {
        this.realLength = capacity;
        this._length = 0;
        auto size = this.realLength * T.sizeof;
        this.ptr = cast(T*)malloc(size)[0..size].ptr;
        this.valid = true;
        GC.addRange(this.ptr, size);
    }

    void destroy() {
        GC.removeRange(cast(void*)this.ptr);
        free(cast(void*)this.ptr);
        this.valid = false;
    }

    void opOpAssign(string op)(T value) if (op == "~") in {
        assert(this.valid, invalidMessage);
    } body {
        this.incLength(1);
        this[this._length-1] = value;
    }

    void opOpAssign(string op)(Array!T value) if (op == "~") in {
        assert(this.valid, invalidMessage);
    } body {
        auto oldLength = this._length;
        this.incLength(value._length);
        foreach (i; 0..value._length) {
            this[oldLength + i] = value[i];
        }
    }

    ref T opIndex(size_t idx) in {
        assert(0 <= idx && idx < this._length, "Out of Range");
        assert(valid, invalidMessage);
    } body {
        return this.ptr[idx];
    }

    bool empty() {
        return this._length == 0;
    }

    T front() {
        return this.ptr[0];
    }

    T popFront() {
        auto res = this.ptr[0];
        this.ptr = &this.ptr[1];
        this._length--;
        return res;
    }

    int opApply(int delegate(ref T) dg) in {
        assert(this.valid, invalidMessage);
    } body {
        int result = 0;
        foreach (i; 0..this._length) {
            result = dg(this[i]);
            if (result) break;
        }
        return result;
    }

    void filter(string po)() {
        auto len = 0;
        foreach (i; 0..this._length) {
            auto a = this[i];
            if (!mixin(po)) continue;
            this[len++] = this[i];
        }
        this._length = len;
    }

    private void incLength(size_t _length) out {
        assert(this.ptr);
    } body {
        this._length += _length;
        if (this._length > this.realLength) {
            this.realLength = this._length + 10;
            auto size = this.realLength * T.sizeof;
            GC.removeRange(this.ptr);
            this.ptr = cast(T*)realloc(this.ptr, size)[0..size];
            GC.addRange(this.ptr, size);
        }
    }

    size_t length() {
        return _length;
    }
}
