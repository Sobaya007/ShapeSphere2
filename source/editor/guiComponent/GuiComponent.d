module editor.guiComponent.GuiComponent;

import sbylib;
import editor.guiComponent;

interface GuiComponent : IControllable {

    float x() @property;
    float x(float) @property;
    float y() @property;
    float y(float) @property;
    size_t zIndex() @property;
    size_t zIndex(size_t) @property;
    float width() @property;
    float height() @property;

}

package(editor.guiComponent) abstract class AGuiComponent : GuiComponent {

private:
    Entity mEntity;

    size_t _zIndex = 0;
    const float _zDetail = 0.1;

public:
    // zIndexが大きいほど手前で描画される
    this(Entity entity = null, bool createColEntryFlag = true) {
        mEntity = entity is null ? new Entity : entity;
        if (mEntity.mesh.isJust && createColEntryFlag) {
            mEntity.buildBVH();
        }
        mEntity.setUserData("controllable", cast(IControllable)this);
    }

    override float x() {
        return entity.obj.pos.x;
    }
    override float x(float value) {
        return entity.obj.pos.x = value;
    }

    override float y() {
        return entity.obj.pos.y;
    }
    override float y(float value) {
        return entity.obj.pos.y = value;
    }

    override size_t zIndex() {
        return _zIndex;
    }
    override size_t zIndex(size_t value) {
        _zIndex = value;
        entity.obj.pos.z = _zDetail * _zIndex;
        return _zIndex;
    }

    abstract override float width();
    abstract override float height();

    override Entity entity() {
        return mEntity;
    }

    override void onMousePressed(MouseButton mouseButton) {}
    override void onMouseReleased(MouseButton mouseButton, bool isCollided) {}
    override void onKeyPressed(KeyButton keyButton, bool shiftPressed, bool controlPressed) {}
    override void onKeyReleases(KeyButton keyButton, bool shiftPressed, bool controlPressed) {}
    override void update(ViewportMouse mouse, Maybe!IControllable activeControllable) {}

}
