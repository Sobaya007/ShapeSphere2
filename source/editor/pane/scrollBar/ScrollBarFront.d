module editor.pane.scrollBar.ScrollBarFront;

import sbylib;

class ScrollBarFront : IControllable {

private:
    Entity _entity;

    float _width;
    float _height;
    int _viewportHeight;

    float _offsetY;
    float _mouseOffsetY;
    float _mouseY;

    bool _keyPressed = false;

public:
    this(float width, float height, int viewportHeight) {
        _width = width;
        _height = height;
        _viewportHeight = viewportHeight;

        auto geom = Rect.create(width, height, Rect.OriginX.Left, Rect.OriginY.Top);
        auto entity = new EntityTemp!(GeometryRect, ColorMaterial)(geom);
        entity.getMesh.mat.color = vec4(0, 1, 1, 1); // debug

        entity.setUserData(cast(IControllable)this);
        entity.createCollisionPolygon();
        entity.pos.z = 2;

        _entity = entity;
    }

    override Entity getEntity() {
        return _entity;
    }

    override void onMousePressed(MouseButton mouseButton) {
        _offsetY = _entity.pos.y;
        _mouseOffsetY = _mouseY;
        _keyPressed = true;
    }

    override void onMouseReleased(MouseButton mouseButton, bool isCollided) {
        _keyPressed = false;
    }

    override void onKeyPressed(KeyButton keyButton, bool shiftPressed, bool controlPressed) {

    }

    override void onKeyReleases(KeyButton keyButton, bool shiftPressed, bool controlPressed) {

    }

    override void update(ViewportMouse mouse, Maybe!IControllable activeControllable) {
        _mouseY = mouse.getPos().y;

        if (_keyPressed) {
            _entity.pos.y = _offsetY + _viewportHeight*(_mouseY - _mouseOffsetY)/2;
        }
    }
}
