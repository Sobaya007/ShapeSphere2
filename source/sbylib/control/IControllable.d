module sbylib.control.IControllable;

public {
    import sbylib.input.Mouse;
    import sbylib.input.Mouse2D;
    import sbylib.collision.CollisionEntry;
}

interface IControllable {
    Entity getEntity();
    void onMousePressed(MouseButton mouseButton);
    void onMouseReleased(MouseButton mouseButton, bool isCollided);
    void onKeyPressed(KeyButton keyButton, bool shiftPressed, bool controlPressed);
    void onKeyReleases(KeyButton keyButton, bool shiftPressed, bool controlPressed);
    void update(Mouse2D mouse);
    void activeUpdate(Mouse2D mouse);
}
