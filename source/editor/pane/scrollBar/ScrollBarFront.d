module editor.pane.scrollBar.ScrollBarFront;

import sbylib;

class ScrollBarFront : IControllable {

private:
    Entity mEntity;

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
        auto entity = makeEntity(geom, new ColorMaterial);
        entity.color = vec4(0, 1, 1, 1); // debug

        entity.setUserData("controllable", cast(IControllable)this);
        entity.buildBVH();
        entity.pos.z = 2;

        mEntity = entity;
    }

    override Entity entity() {
        return mEntity;
    }

    override void onMousePressed(MouseButton mouseButton) {
        _offsetY = mEntity.pos.y;
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
        _mouseY = mouse.pos.y;

        if (_keyPressed) {
            mEntity.pos.y = _offsetY + _viewportHeight*(_mouseY - _mouseOffsetY)/2;
        }
    }
}
