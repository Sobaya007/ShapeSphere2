module editor.pane.scrollBar.ScrollBarBack;

import sbylib;

class ScrollBarBack : IControllable {

private:
    Entity _entity;

public:
    this(float width, float height) {
        auto geom = Rect.create(width, height, Rect.OriginX.Left, Rect.OriginY.Top);
        auto entity = new EntityTemp!(GeometryRect, ColorMaterial)(geom);
        entity.getMesh.mat.color = vec4(0, 1, 0, 1); // debug

        entity.setUserData(cast(IControllable)this);
        entity.createCollisionPolygon();
        entity.pos.z = 1;

        _entity = entity;
    }

    override Entity getEntity() {
        return _entity;
    }

    override void onMousePressed(MouseButton mouseButton) {

    }

    override void onMouseReleased(MouseButton mouseButton, bool isCollided) {

    }

    override void onKeyPressed(KeyButton keyButton, bool shiftPressed, bool controlPressed) {

    }

    override void onKeyReleases(KeyButton keyButton, bool shiftPressed, bool controlPressed) {

    }

    override void update(ViewportMouse mouse, Maybe!IControllable activeControllable) {

    }
}
