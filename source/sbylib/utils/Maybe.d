module sbylib.utils.Maybe;

struct Maybe(T) {
    private T value;
    private bool _nothing;

    this(T value) {
        this.value = value;
        this._nothing = false;
    }

    this() {
        this._nothing = true;
    }

    T just() {
    }

}
