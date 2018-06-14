module editor.pane.scrollBar.ScrollBarBack;

import sbylib;

class ScrollBarBack : IControllable {

private:
    Entity mEntity;

public:
    this(float width, float height) {
        auto geom = Rect.create(width, height, Rect.OriginX.Left, Rect.OriginY.Top);
        auto entity = makeEntity(geom, new ColorMaterial);
        entity.color = vec4(0, 1, 0, 1); // debug

        entity.setUserData("controllable", cast(IControllable)this);
        entity.buildBVH();
        entity.pos.z = 1;

        mEntity = entity;
    }

    override Entity entity() {
        return mEntity;
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
