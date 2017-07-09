module sbylib.control.IControllable;

public {
    import sbylib.input.Mouse;
    import sbylib.input.Mouse2D;
    import sbylib.collision.ICollidable;
}

interface IControllable {
    ICollidable getCollidable();
    void onMousePressed(MouseButton button);
    void onMouseReleased(MouseButton button);
    void update(Mouse2D);
}
