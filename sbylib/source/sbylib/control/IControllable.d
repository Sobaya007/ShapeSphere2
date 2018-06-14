module sbylib.control.IControllable;

public {
    import sbylib.input.Mouse;
    import sbylib.input.ViewportMouse;
    import sbylib.collision.CollisionEntry;
}

interface IControllable {
    Entity entity();
    void onMousePressed(MouseButton mouseButton);
    void onMouseReleased(MouseButton mouseButton, bool isCollided);
    void onKeyPressed(KeyButton keyButton, bool shiftPressed, bool controlPressed);
    void onKeyReleases(KeyButton keyButton, bool shiftPressed, bool controlPressed);
    void update(ViewportMouse mouse, Maybe!IControllable activeControllable);
}
