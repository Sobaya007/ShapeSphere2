module sbylib.control.IControllable;

public {
    import sbylib.input.Mouse;
    import sbylib.input.Mouse2D;
    import sbylib.collision.CollisionEntry;
}

interface IControllable {
    Entity getEntity();
    void onMousePressed(MouseButton);
    void onMouseReleased(MouseButton);
    void update(Mouse2D);
}
