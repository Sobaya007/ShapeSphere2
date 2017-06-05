module sbylib.utils.LimitedArray;

class LimitedArray(T, size_t S) {

private:
    T[] elements = new T[S];
    size_t _length = 0;

public:
    void add(T elem) {
        elements[_length++] = elem;
        if (_length == elements.length) {
            elements.length = elements.length * 2;
        }
    }

    @nogc clear() {
        _length = 0;
    }

    @nogc size_t length() {
        return _length;
    }

    @nogc ref T opIndex(size_t n) {
        return elements[n];
    }

    int opApply(int delegate(ref T) dg) {
        int result = 0;
        int idx = 0;
        while (idx < _length) {
            result = dg(elements[idx]);
            if (result) break;
            idx++;
        }
        return result;
    }

    T front() {
        return elements[0];
    }

    void popFront() {
        foreach (i; 0.._length) {
            elements[i] = elements[i+1];
        }
        _length--;
    }

    bool empty() {
        return length == 0;
    }

    LimitedArray save() {
        LimitedArray!(T, S) result;
        result.elements = this.elements.dup;
        result._length = this._length;
        return result;
    }

    T back() {
        return elements[_length-1];
    }

    void popBack() {
        _length--;
    }
}
