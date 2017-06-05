module sbylib.utils.LinkList;

struct LinkList(T) {

    class Node {
        T elem;
        Node prev, next;
        this(T elem) {this.elem = elem;}

        void remove() @nogc {
            if (prev) prev.next = next;
            if (next) next.prev = prev;
        }
    }

    private {
        Node last;
        bool isAllocated;
        size_t _length; // Stackに入ってるNodeの数
        Node[] allocatedNodes = [];
    }

    size_t length() {
        return _length;
    }

    Node push(T elem) in {
        assert(!isAllocated || length < allocatedNodes.length);
    } body {
        if (last is null) {
            if (isAllocated) {
                last = allocatedNodes[length];
                last.elem = elem;
                last.next = null;
            } else {
                last = new Node(elem);
            }
            _length++;
            return this.last;
        }
        Node next;
        if (isAllocated) {
            next = allocatedNodes[length];
            next.elem = elem;
            next.next = null;
        } else {
            next = new Node(elem);
        }
        last.next = next;
        next.prev = last;
        this.last = next;
        _length++;
        return this.last;
    }

    void pop() @nogc in {
        assert(length > 0);
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

    struct Iterator {
        private Node current;

        this(Node node) {
            this.current = node;
        }

        T next() @nogc {
            auto result = current;
            current = current.next;
            return result.elem;
        }

        bool hasNext() @nogc {
            return current !is null;
        }

        void remove() @nogc {
            current.prev.remove();
        }
    }

    Iterator iterator() @nogc {
        auto current = last;
        if (current is null) return Iterator(null);
        while (current.prev) current = current.prev;
        return Iterator(current);
    }

    alias insertBack = push;
}
