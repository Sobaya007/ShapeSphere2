module sbylib.input.Clipboard;

import sbylib.core.Window;

class Clipboard {
    private Window window;

    package(sbylib) this(Window window) {
        this.window = window;
    }

    void set(string str) {
        this.window.setClipboardString(str);
    }

    string get() {
        return this.window.getClipboardString();
    }
}
