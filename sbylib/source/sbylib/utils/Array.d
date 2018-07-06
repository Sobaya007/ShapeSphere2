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

    this(size_t capacity)
        out(; this.ptr)
    {
        this.realLength = capacity;
        this._length = 0;
        auto size = this.realLength * T.sizeof;
        this.ptr = cast(T*)malloc(size)[0..size].ptr;
        this.valid = true;
        GC.addRange(this.ptr, size);
    }

    void destroy()
        in(this.valid, invalidMessage)
    {
        GC.removeRange(cast(void*)this.ptr);
        free(cast(void*)this.ptr);
        this.valid = false;
    }

    void add(T value)
        in(this.valid, invalidMessage)
    {
        this.incLength(1);
        this[this._length-1] = value;
    }

    void opOpAssign(string op)(T value) if (op == "~") {
        add(value);
    }

    void opOpAssign(string op)(Array!T value) if (op == "~") 
        in(this.valid, invalidMessage)
    {
        auto oldLength = this._length;
        this.incLength(value._length);
        foreach (i; 0..value._length) {
            this[oldLength + i] = value[i];
        }
    }

    ref T opIndex(size_t idx)
        in(0 <= idx, format!"index must not be negative. index is %d."(idx))
        in(idx < length, format!"index must be less than %d. index is %d."(this.length, idx))
        in(valid, invalidMessage)
    {
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

    int opApply(int delegate(size_t, ref T) dg)
        in(this.valid, invalidMessage)
    {
        int result = 0;
        size_t pos = 0;
        while (pos < this._length) {
            result = dg(pos, this[pos]);
            pos++;
            if (result) break;
        }
        return result;
    }

    int opApply(int delegate(ref T) dg)
        in(this.valid, invalidMessage)
    {
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

    private void incLength(size_t _length)
        out(; this.ptr)
    {
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

void sort(alias lessThan = (a,b) => a < b, T)(Array!T array) {
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

unittest {
    import std.random, std.range, std.array;
    import algorithm = std.algorithm;

    auto array = algorithm.map!(_ => uniform(-100000, 100000))(iota(1000)).array;

    auto array2 = Array!int(1000);

    foreach (a; array) {
        array2 ~= a;
    }

    algorithm.sort(array);
    sort(array2);

    foreach (i; 0..1000) {
        assert(array[i] == array2[i]);
    }
}
