module sbylib.utils.Selection;

enum SelectionStrategy {Repeat, Clamp}

class Selection(T) {

    import sbylib.utils.Array;

    alias Callback = void delegate(T);
    alias CallbackList = Array!(Callback);

    class Handler {
        T content;
        CallbackList onFocusIn;
        CallbackList onFocusOut;
        CallbackList onSelect;

        this(T content) {
            this.content = content;
            this.onFocusIn = CallbackList(0);
            this.onFocusOut = CallbackList(0);
            this.onSelect = CallbackList(0);
        }

        void focusIn() {
            foreach (f; this.onFocusIn) {
                f(this.content);
            }
        }

        void focusOut() {
            foreach (f; this.onFocusOut) {
                f(this.content);
            }
        }

        void select() {
            foreach (f; this.onSelect) {
                f(this.content);
            }
        }
    }

    private Handler[] handlers;
    private SelectionStrategy strategy;
    private size_t cursor;

    this(SelectionStrategy strategy) {
        this.strategy = strategy;
    }

    Handler register(T content) {
        auto handler = new Handler(content);
        handlers ~= handler;
        return handler;
    }

    void prev() {
        cursorMove(&prevImpl);
    }

    void next() {
        cursorMove(&nextImpl);
    }

    void select() {
        this.handlers[cursor].select();
    }

    Handler[] getHandlers() { return this.handlers; }
    alias getHandlers this;

    private void cursorMove(void delegate() move) 
        in(handlers.length > 0)
    {
        auto before = cursor;
        move();
        if (before != cursor) {
            handlers[before].focusOut();
            handlers[cursor].focusIn();
        }
    }

    private void prevImpl() {
        if (0 < cursor) {
            cursor--;
        } else {
            final switch(this.strategy) {
                case SelectionStrategy.Repeat:
                    cursor = handlers.length-1;
                    break;
                case SelectionStrategy.Clamp:
                    cursor = 0;
                    break;
            }
        }
    }

    private void nextImpl() {
        if (cursor < handlers.length-1) {
            cursor++;
        } else {
            final switch(this.strategy) {
                case SelectionStrategy.Repeat:
                    cursor = 0;
                    break;
                case SelectionStrategy.Clamp:
                    cursor = handlers.length-1;
                    break;
            }
        }
    }
}
