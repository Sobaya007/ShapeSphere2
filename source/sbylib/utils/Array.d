module sbylib.utils.Array;

// source from here:https://wiki.dlang.org/Memory_Management
import core.stdc.stdlib;
import core.memory;
import std.string;
import std.format;
import sbylib.utils.Maybe;

struct Array(T) {
    private T* ptr;
    private size_t offset;
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

    void destroy() in {
        assert(this.valid, invalidMessage);
    } body {
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
        assert(0 <= idx, format!"index must not be negative. index is %d."(idx));
        assert(idx < length, format!"index must be less than %d. index is %d."(this.length, idx));
        assert(valid, invalidMessage);
    } body {
        return this.ptr[idx+offset];
    }

    bool empty() {
        return this._length == 0;
    }

    T front() {
        return this[0];
    }

    T popFront() {
        auto res = this[0];
        this.offset++;
        this._length--;
        return res;
    }

    int opApply(int delegate(size_t, ref T) dg) in {
        assert(this.valid, invalidMessage);
    } body {
        int result = 0;
        size_t pos = 0;
        while (pos < this._length) {
            result = dg(pos, this[pos]);
            pos++;
            if (result) break;
        }
        return result;
    }

    int opApply(int delegate(ref T) dg) in {
        assert(this.valid, invalidMessage);
    } body {
        int result = 0;
        auto pos = 0;
        while (pos < this._length) {
            result = dg(this[pos]);
            pos++;
            if (result) break;
        }
        return result;
    }

    void filter(bool function(T) cond)() {
        auto len = 0;
        foreach (a; this) {
            if (!cond(a)) continue;
            this[len++] = a;
        }
        this._length = len;
    }

    Maybe!T find(bool function(T) cond)() {
        foreach (a; this) {
            if (cond(a)) return Just(a);
        }
        return None!T;
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

void sort(alias lessThan, T)(Array!T array) {
    if (array.length == 0) return;
    sort!(lessThan, T)(array, 0, array.length-1);
}

private void sort(alias lessThan, T)(Array!T array, size_t begin, size_t end) {
    if (begin >= end) return;
    auto pivot = array[(begin+end)/2];
    auto left = begin;
    assert(end != 0);
    auto right = end;
    while (true) {
        while (lessThan(array[left],pivot)) left++;
        while (0 < right && lessThan(pivot,array[right])) right--;
        auto tmp = array[left];
        if (left >= right) break;
        array[left] = array[right];
        array[right] = tmp;
        left++;
        right--;
    }
    if (left > 0) sort!(lessThan, T)(array, begin, left-1);
    sort!(lessThan, T)(array, right+1, end);
}
