module sbylib.input.Key;

public {
    import sbylib.wrapper.glfw.Window;
    import sbylib.wrapper.glfw.Constants;
}

class Key {
    private Window window;

    package(sbylib) this(Window window) {
        this.window = window;
    }

    bool get(KeyButton key) {
        return this.window.getKey(key);
    }

    bool opIndex(KeyButton key) {
        return this.get(key);
    }
}
