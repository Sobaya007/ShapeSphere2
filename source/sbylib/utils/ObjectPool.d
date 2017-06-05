module sbylib.utils.ObjectPool;

class ObjectPool(T, size_t S) {

    private {
        T[] elements;
        size_t _length;
    }

    this() {
        elements.length = S;
        _length = 0;

        foreach (i; 0..S) elements[i] = new T;
    }

    T get() {
        auto result = elements[_length++];
        if (_length == elements.length) {
            auto start = elements.length;
            elements.length = elements.length * 2;
            foreach (i; start..elements.length) {
                elements[i] = new T;
            }
        }
        return result;
    }

    void clear() {
        _length = 0;
    }
}
