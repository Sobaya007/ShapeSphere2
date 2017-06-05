module sbylib.utils.Stack;
import std.conv;


struct Stack(T) {

    private class Node {
        T elem;
        Node prev, next;
        this(T elem) {this.elem = elem;}
    }

    private {
        Node last;
        bool isAllocated;
        size_t _length; // Stackに入ってるNodeの数
        Node[] allocatedNodes = [];
    }

    void push(T elem) {
        if (isAllocated && _length >= allocatedNodes.length) {
            allocate(_length * 3 / 2);
        }
        if (last is null) {
            if (isAllocated) {
                last = allocatedNodes[_length];
                last.elem = elem;
                last.next = null;
            } else {
                last = new Node(elem);
            }
            _length++;
            return;
        }
        Node next;
        if (isAllocated) {
            next = allocatedNodes[_length];
            next.elem = elem;
            next.next = null;
        } else {
            next = new Node(elem);
        }
        last.next = next;
        next.prev = last;
        this.last = next;
        _length++;
    }

    void pop() @nogc in {
        assert(_length > 0);
    } body {
        if (last.prev is null) {
            last = null;
            return;
        }
        auto n = last.prev;
        n.next = null;
        this.last = n;
        _length--;
    }

    bool remove(T elem) @nogc {
        auto current = last;
        auto i = length-1;
        bool flag = false;
        while (current) {
            if (current.elem is elem) {
                flag = true; 
                break;
            }
            i--;
            current = current.prev;
        }
        if (flag) {
            if (current.next)
                current.next.prev = current.prev;
            if (current.prev)
                current.prev.next = current.next;
            if (isAllocated)
                allocatedNodes[i..$-1] = allocatedNodes[i+1..$];
            _length--;
        }
        return flag;
    }

    int opApply(int delegate(ref T) dg) {
        auto current = last;
        if (current is null) return 0;
        while (current.prev) current = current.prev;
        int result = 0;
        while (current) {
            result = dg(current.elem);
            if (result) break;
            current = current.next;
        }
        return result;
    }

    void clear() @nogc {
        _length = 0;
        last = null;
    }

    bool isEmpty() @nogc {
        return _length == 0;
    }

    T getLast() @nogc {
        return last.elem;
    }

    void allocate(size_t leng) in {
        assert(leng >= _length);
        assert(leng >= allocatedNodes.length);
    } body {
        if (isAllocated) {
            auto before = allocatedNodes.length;
            allocatedNodes.length = leng;
            foreach (i; before..leng) {
                allocatedNodes[i] = new Node(T.init);
            }
        } else {
            allocatedNodes.length = leng;
            size_t i = _length;
            Node current = last;
            while(current) {
                allocatedNodes[--i] = current;
                current = current.next;
            }
            assert(i == 0);
            i = _length;
            for(; i<allocatedNodes.length; i++) {
                allocatedNodes[i] = new Node(T.init);
            }
            isAllocated = true; // 静的配列モード
        }
    }

    size_t length() {
        return _length;
    }

    alias removeBack = pop;
    alias insertBack = push;
}
